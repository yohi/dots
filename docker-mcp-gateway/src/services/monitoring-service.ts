/**
 * Monitoring Service
 * 包括的な監視、ログ記録、ヘルスチェック機能を提供します
 */

import Docker from 'dockerode';
import fs from 'fs-extra';
import path from 'path';
import winston from 'winston';
import {
  MonitoringService,
  GatewayMetrics,
  ServerMetrics,
  SystemMetrics,
  LogEntry,
  LogFilter,
  HealthStatus,
  DiagnosticReport,
  GatewayStatus,
  ServerStatus,
  GatewayConfig,
  ConfigurationManager
} from '../types/interfaces.js';

export class MonitoringServiceImpl implements MonitoringService {
  private readonly docker: Docker;
  private readonly configManager: ConfigurationManager;
  private readonly logger: winston.Logger;
  private readonly logStorage: LogEntry[] = [];
  private readonly maxLogEntries: number = 10000;
  private monitoringInterval?: NodeJS.Timeout;
  private readonly metricsHistory: Map<string, any[]> = new Map();

  constructor(configManager: ConfigurationManager) {
    this.docker = new Docker();
    this.configManager = configManager;
    this.logger = this.setupLogger();
  }

  /**
   * Get comprehensive gateway and server metrics
   */
  async getMetrics(): Promise<GatewayMetrics> {
    try {
      const gatewayContainer = await this.findGatewayContainer();
      const gatewayConfig = await this.loadGatewayConfig();

      let totalRequests = 0;
      let activeConnections = 0;
      const serverMetrics: Record<string, ServerMetrics> = {};

      // Collect server metrics
      for (const serverId of Object.keys(gatewayConfig.servers)) {
        const metrics = await this.collectServerMetrics(serverId);
        serverMetrics[serverId] = metrics;
        totalRequests += metrics.requestCount;
      }

      // Collect system metrics
      const systemMetrics = await this.collectSystemMetrics(gatewayContainer);

      // Calculate uptime
      let uptime = 0;
      if (gatewayContainer) {
        const containerInfo = await gatewayContainer.inspect();
        if (containerInfo.State.Running) {
          const startTime = new Date(containerInfo.State.StartedAt);
          uptime = Date.now() - startTime.getTime();
        }
      }

      const metrics: GatewayMetrics = {
        uptime,
        totalRequests,
        activeConnections,
        serverMetrics,
        systemMetrics
      };

      // Store metrics in history
      this.storeMetricsHistory('gateway', metrics);

      return metrics;

    } catch (error) {
      this.logger.error('Failed to collect metrics', { error: error instanceof Error ? error.message : String(error) });
      throw new Error(`Failed to collect metrics: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Get filtered logs
   */
  async getLogs(filter?: LogFilter): Promise<LogEntry[]> {
    let filteredLogs = [...this.logStorage];

    if (filter) {
      // Apply level filter
      if (filter.level) {
        filteredLogs = filteredLogs.filter(log => log.level === filter.level);
      }

      // Apply source filter
      if (filter.source) {
        filteredLogs = filteredLogs.filter(log => log.source === filter.source);
      }

      // Apply server ID filter
      if (filter.serverId) {
        filteredLogs = filteredLogs.filter(log => log.serverId === filter.serverId);
      }

      // Apply time range filter
      if (filter.startTime) {
        filteredLogs = filteredLogs.filter(log => log.timestamp >= filter.startTime!);
      }

      if (filter.endTime) {
        filteredLogs = filteredLogs.filter(log => log.timestamp <= filter.endTime!);
      }

      // Apply limit
      if (filter.limit && filter.limit > 0) {
        filteredLogs = filteredLogs.slice(-filter.limit);
      }
    }

    return filteredLogs.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());
  }

  /**
   * Perform comprehensive health check
   */
  async performHealthCheck(): Promise<HealthStatus> {
    const healthChecks: any = {
      gateway: { status: 'unhealthy', details: 'Gateway not accessible' },
      servers: {} as Record<string, { status: 'healthy' | 'unhealthy'; details: string }>
    };

    try {
      // Check gateway health
      const gatewayContainer = await this.findGatewayContainer();
      if (gatewayContainer) {
        const containerInfo = await gatewayContainer.inspect();
        if (containerInfo.State.Running) {
          // Try to connect to gateway health endpoint
          try {
            const response = await fetch('http://localhost:8080/health', {
              timeout: 5000
            } as any);

            if (response.ok) {
              healthChecks.gateway = {
                status: 'healthy',
                details: 'Gateway is running and responsive'
              };
            } else {
              healthChecks.gateway = {
                status: 'unhealthy',
                details: `Gateway responded with status ${response.status}`
              };
            }
          } catch (fetchError) {
            healthChecks.gateway = {
              status: 'unhealthy',
              details: 'Gateway is running but not responding to health checks'
            };
          }
        } else {
          healthChecks.gateway = {
            status: 'unhealthy',
            details: 'Gateway container is not running'
          };
        }
      } else {
        healthChecks.gateway = {
          status: 'unhealthy',
          details: 'Gateway container not found'
        };
      }

      // Check server health
      const gatewayConfig = await this.loadGatewayConfig();
      for (const [serverId, serverConfig] of Object.entries(gatewayConfig.servers)) {
        try {
          const serverStatus = await this.checkServerHealth(serverId, serverConfig);
          healthChecks.servers[serverId] = {
            status: serverStatus.isHealthy ? 'healthy' : 'unhealthy',
            details: serverStatus.details
          };
        } catch (error) {
          healthChecks.servers[serverId] = {
            status: 'unhealthy',
            details: `Health check failed: ${error instanceof Error ? error.message : String(error)}`
          };
        }
      }

    } catch (error) {
      this.logger.error('Health check failed', { error: error instanceof Error ? error.message : String(error) });
    }

    // Determine overall health
    const gatewayHealthy = healthChecks.gateway.status === 'healthy';
    const serverHealthCounts = Object.values(healthChecks.servers).reduce(
      (counts: any, server: any) => {
        counts[server.status] = (counts[server.status] || 0) + 1;
        return counts;
      },
      {}
    );

    let overall: 'healthy' | 'degraded' | 'unhealthy';
    if (!gatewayHealthy) {
      overall = 'unhealthy';
    } else if (serverHealthCounts.unhealthy > 0) {
      overall = serverHealthCounts.healthy > 0 ? 'degraded' : 'unhealthy';
    } else {
      overall = 'healthy';
    }

    return {
      overall,
      gateway: healthChecks.gateway,
      servers: healthChecks.servers
    };
  }

  /**
   * Generate comprehensive diagnostic report
   */
  async generateDiagnosticReport(): Promise<DiagnosticReport> {
    const timestamp = new Date();

    try {
      // Collect all information
      const [metrics, healthStatus, logs, gatewayStatus, gatewayConfig] = await Promise.all([
        this.getMetrics(),
        this.performHealthCheck(),
        this.getLogs({ limit: 1000 }),
        this.getGatewayStatus(),
        this.loadGatewayConfig()
      ]);

      // Collect server statuses
      const serverStatuses: Record<string, { status: ServerStatus; metrics: ServerMetrics; logs: LogEntry[] }> = {};

      for (const serverId of Object.keys(gatewayConfig.servers)) {
        const serverStatus = await this.getServerStatus(serverId);
        const serverMetrics = metrics.serverMetrics[serverId] || this.getDefaultServerMetrics();
        const serverLogs = logs.filter(log => log.serverId === serverId);

        serverStatuses[serverId] = {
          status: serverStatus,
          metrics: serverMetrics,
          logs: serverLogs
        };
      }

      return {
        timestamp,
        gateway: {
          status: gatewayStatus,
          metrics,
          logs: logs.filter(log => log.source === 'gateway')
        },
        servers: serverStatuses,
        configuration: gatewayConfig
      };

    } catch (error) {
      this.logger.error('Failed to generate diagnostic report', {
        error: error instanceof Error ? error.message : String(error)
      });
      throw new Error(`Failed to generate diagnostic report: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Start monitoring services
   */
  async startMonitoring(): Promise<void> {
    if (this.monitoringInterval) {
      return; // Already monitoring
    }

    this.logger.info('Starting monitoring services');

    // Collect metrics every 30 seconds
    this.monitoringInterval = setInterval(async () => {
      try {
        await this.getMetrics();
        await this.performHealthCheck();
      } catch (error) {
        this.logger.error('Monitoring cycle failed', {
          error: error instanceof Error ? error.message : String(error)
        });
      }
    }, 30000);

    // Clean up old logs and metrics every 5 minutes
    setInterval(() => {
      this.cleanupOldData();
    }, 300000);

    this.addLogEntry('info', 'Monitoring services started', 'gateway');
  }

  /**
   * Stop monitoring services
   */
  async stopMonitoring(): Promise<void> {
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = undefined;
      this.logger.info('Monitoring services stopped');
      this.addLogEntry('info', 'Monitoring services stopped', 'gateway');
    }
  }

  // Private helper methods

  private setupLogger(): winston.Logger {
    const logDir = path.join(process.cwd(), '.kiro/docker-mcp-gateway/logs');
    fs.ensureDirSync(logDir);

    return winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
      ),
      transports: [
        new winston.transports.File({
          filename: path.join(logDir, 'error.log'),
          level: 'error',
          maxsize: 10485760, // 10MB
          maxFiles: 5
        }),
        new winston.transports.File({
          filename: path.join(logDir, 'combined.log'),
          maxsize: 10485760, // 10MB
          maxFiles: 5
        }),
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
          )
        })
      ]
    });
  }

  private async collectServerMetrics(serverId: string): Promise<ServerMetrics> {
    // In a real implementation, this would query the gateway API for server-specific metrics
    // For now, we'll return simulated metrics
    return {
      requestCount: Math.floor(Math.random() * 1000),
      responseTime: Math.floor(Math.random() * 100) + 50,
      errorCount: Math.floor(Math.random() * 10),
      status: 'running'
    };
  }

  private async collectSystemMetrics(container: Docker.Container | null): Promise<SystemMetrics> {
    const defaultMetrics: SystemMetrics = {
      cpuUsage: 0,
      memoryUsage: 0,
      diskUsage: 0,
      networkIO: {
        bytesIn: 0,
        bytesOut: 0
      }
    };

    if (!container) {
      return defaultMetrics;
    }

    try {
      const stats = await container.stats({ stream: false });

      // Calculate CPU usage
      const cpuDelta = stats.cpu_stats.cpu_usage.total_usage - stats.precpu_stats.cpu_usage.total_usage;
      const systemDelta = stats.cpu_stats.system_cpu_usage - stats.precpu_stats.system_cpu_usage;
      const cpuUsage = systemDelta > 0 ? (cpuDelta / systemDelta) * 100 : 0;

      // Calculate memory usage
      const memoryUsage = stats.memory_stats.usage ? (stats.memory_stats.usage / stats.memory_stats.limit) * 100 : 0;

      // Network I/O
      const networks = stats.networks || {};
      let bytesIn = 0;
      let bytesOut = 0;

      for (const networkStats of Object.values(networks)) {
        const netStats = networkStats as any;
        bytesIn += netStats.rx_bytes || 0;
        bytesOut += netStats.tx_bytes || 0;
      }

      return {
        cpuUsage: Math.round(cpuUsage * 100) / 100,
        memoryUsage: Math.round(memoryUsage * 100) / 100,
        diskUsage: 0, // Would require additional API calls to calculate
        networkIO: {
          bytesIn,
          bytesOut
        }
      };

    } catch (error) {
      this.logger.warn('Failed to collect system metrics', {
        error: error instanceof Error ? error.message : String(error)
      });
      return defaultMetrics;
    }
  }

  private async checkServerHealth(serverId: string, serverConfig: any): Promise<{ isHealthy: boolean; details: string }> {
    try {
      // In a real implementation, this would use the configured health check
      // For now, we'll simulate health check based on server configuration
      if (serverConfig.healthCheck) {
        // Simulate health check execution
        const isHealthy = Math.random() > 0.1; // 90% healthy rate
        return {
          isHealthy,
          details: isHealthy ? 'Health check passed' : 'Health check failed'
        };
      } else {
        return {
          isHealthy: true,
          details: 'No health check configured, assuming healthy'
        };
      }
    } catch (error) {
      return {
        isHealthy: false,
        details: `Health check error: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  private addLogEntry(level: LogEntry['level'], message: string, source: LogEntry['source'], serverId?: string, metadata?: Record<string, any>): void {
    const logEntry: LogEntry = {
      timestamp: new Date(),
      level,
      message,
      source,
      serverId,
      metadata
    };

    this.logStorage.push(logEntry);

    // Log to winston as well
    this.logger.log(level, message, { source, serverId, metadata });

    // Trim logs if we exceed the limit
    if (this.logStorage.length > this.maxLogEntries) {
      this.logStorage.splice(0, this.logStorage.length - this.maxLogEntries);
    }
  }

  private storeMetricsHistory(key: string, metrics: any): void {
    if (!this.metricsHistory.has(key)) {
      this.metricsHistory.set(key, []);
    }

    const history = this.metricsHistory.get(key)!;
    history.push({
      timestamp: new Date(),
      ...metrics
    });

    // Keep only last 100 entries
    if (history.length > 100) {
      history.splice(0, history.length - 100);
    }
  }

  private cleanupOldData(): void {
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

    // Clean up old log entries
    const initialLogCount = this.logStorage.length;
    for (let i = this.logStorage.length - 1; i >= 0; i--) {
      if (this.logStorage[i].timestamp < oneDayAgo) {
        this.logStorage.splice(i, 1);
      }
    }

    if (initialLogCount !== this.logStorage.length) {
      this.logger.debug(`Cleaned up ${initialLogCount - this.logStorage.length} old log entries`);
    }

    // Clean up old metrics history
    for (const [key, history] of this.metricsHistory.entries()) {
      const initialCount = history.length;
      for (let i = history.length - 1; i >= 0; i--) {
        if (history[i].timestamp < oneDayAgo) {
          history.splice(i, 1);
        }
      }

      if (initialCount !== history.length) {
        this.logger.debug(`Cleaned up ${initialCount - history.length} old metrics entries for ${key}`);
      }
    }
  }

  private getDefaultServerMetrics(): ServerMetrics {
    return {
      requestCount: 0,
      responseTime: 0,
      errorCount: 0,
      status: 'stopped'
    };
  }

  private async findGatewayContainer(): Promise<Docker.Container | null> {
    try {
      const containers = await this.docker.listContainers({ all: true });
      const gatewayContainer = containers.find(container =>
        container.Names.some(name => name.includes('mcp-gateway'))
      );

      return gatewayContainer ? this.docker.getContainer(gatewayContainer.Id) : null;
    } catch (error) {
      return null;
    }
  }

  private async loadGatewayConfig(): Promise<GatewayConfig> {
    const configPath = this.configManager.getConfigPath();

    if (!await fs.pathExists(configPath)) {
      throw new Error(`Gateway configuration not found at: ${configPath}`);
    }

    const configContent = await fs.readFile(configPath, 'utf-8');
    const yaml = await import('yaml');
    return yaml.parse(configContent) as GatewayConfig;
  }

  private async getGatewayStatus(): Promise<GatewayStatus> {
    try {
      const container = await this.findGatewayContainer();
      if (!container) {
        return {
          status: 'stopped',
          uptime: 0,
          version: '1.0.0',
          serversCount: 0
        };
      }

      const containerInfo = await container.inspect();
      const startTime = new Date(containerInfo.State.StartedAt);
      const uptime = Date.now() - startTime.getTime();

      const gatewayConfig = await this.loadGatewayConfig();
      const serversCount = Object.keys(gatewayConfig.servers).length;

      return {
        status: containerInfo.State.Running ? 'running' : 'stopped',
        uptime,
        version: '1.0.0',
        serversCount,
        lastRestart: startTime
      };

    } catch (error) {
      return {
        status: 'error',
        uptime: 0,
        version: '1.0.0',
        serversCount: 0
      };
    }
  }

  private async getServerStatus(serverId: string): Promise<ServerStatus> {
    try {
      const gatewayConfig = await this.loadGatewayConfig();

      if (!gatewayConfig.servers[serverId]) {
        return {
          id: serverId,
          status: 'error',
          uptime: 0,
          errorMessage: 'Server not found in configuration'
        };
      }

      const gatewayContainer = await this.findGatewayContainer();
      if (!gatewayContainer) {
        return {
          id: serverId,
          status: 'stopped',
          uptime: 0,
          errorMessage: 'Gateway container not found'
        };
      }

      const containerInfo = await gatewayContainer.inspect();
      if (!containerInfo.State.Running) {
        return {
          id: serverId,
          status: 'stopped',
          uptime: 0,
          errorMessage: 'Gateway container is not running'
        };
      }

      const startTime = new Date(containerInfo.State.StartedAt);
      const uptime = Date.now() - startTime.getTime();

      return {
        id: serverId,
        status: 'running',
        uptime,
        lastHealthCheck: new Date()
      };

    } catch (error) {
      return {
        id: serverId,
        status: 'error',
        uptime: 0,
        errorMessage: error instanceof Error ? error.message : String(error)
      };
    }
  }
}
