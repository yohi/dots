/**
 * Docker MCP Gateway - コアインターフェースと型定義
 * design.md仕様に基づく
 */

// ============================================================================
// 設定タイプ
// ============================================================================

export interface MCPConfig {
  mcpServers: Record<string, MCPServerDefinition>;
}

export interface MCPServerDefinition {
  command: string;
  args?: string[];
  env?: Record<string, string>;
}

export interface GatewayConfig {
  version: string;
  gateway: {
    port: number;
    host: string;
    logLevel: 'debug' | 'info' | 'warn' | 'error';
  };
  servers: Record<string, ServerConfig>;
  network: {
    name: string;
    driver: string;
  };
}

export interface ServerConfig {
  id: string;
  name: string;
  image: string;
  command?: string[];
  environment: Record<string, string>;
  volumes?: VolumeMount[];
  healthCheck?: HealthCheckConfig;
  autoRestart: boolean;
}

export interface VolumeMount {
  source: string;
  target: string;
  readonly?: boolean;
}

export interface HealthCheckConfig {
  command: string[];
  interval: number;
  timeout: number;
  retries: number;
}

// ============================================================================
// Status Types
// ============================================================================

export interface GatewayStatus {
  status: 'running' | 'stopped' | 'error';
  uptime: number;
  version: string;
  serversCount: number;
  lastRestart?: Date;
}

export interface ServerStatus {
  id: string;
  status: 'running' | 'stopped' | 'error' | 'starting';
  uptime: number;
  lastHealthCheck?: Date;
  errorMessage?: string;
}

// ============================================================================
// Monitoring Types
// ============================================================================

export interface GatewayMetrics {
  uptime: number;
  totalRequests: number;
  activeConnections: number;
  serverMetrics: Record<string, ServerMetrics>;
  systemMetrics: SystemMetrics;
}

export interface ServerMetrics {
  requestCount: number;
  responseTime: number;
  errorCount: number;
  status: ServerStatus['status'];
}

export interface SystemMetrics {
  cpuUsage: number;
  memoryUsage: number;
  diskUsage: number;
  networkIO: {
    bytesIn: number;
    bytesOut: number;
  };
}

export interface LogEntry {
  timestamp: Date;
  level: 'debug' | 'info' | 'warn' | 'error';
  message: string;
  source: 'gateway' | 'server';
  serverId?: string;
  metadata?: Record<string, any>;
}

export interface LogFilter {
  level?: LogEntry['level'];
  source?: LogEntry['source'];
  serverId?: string;
  startTime?: Date;
  endTime?: Date;
  limit?: number;
}

export interface HealthStatus {
  overall: 'healthy' | 'degraded' | 'unhealthy';
  gateway: {
    status: 'healthy' | 'unhealthy';
    details: string;
  };
  servers: Record<string, {
    status: 'healthy' | 'unhealthy';
    details: string;
  }>;
}

export interface DiagnosticReport {
  timestamp: Date;
  gateway: {
    status: GatewayStatus;
    metrics: GatewayMetrics;
    logs: LogEntry[];
  };
  servers: Record<string, {
    status: ServerStatus;
    metrics: ServerMetrics;
    logs: LogEntry[];
  }>;
  configuration: GatewayConfig;
}

// ============================================================================
// Operation Types
// ============================================================================

export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
  warnings: string[];
}

export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

export interface OperationResult<T = void> {
  success: boolean;
  data?: T;
  error?: string;
  details?: Record<string, any>;
}

// ============================================================================
// Core Service Interfaces
// ============================================================================

export interface ConfigurationManager {
  loadExistingConfig(): Promise<MCPConfig>;
  generateGatewayConfig(mcpConfig: MCPConfig): Promise<GatewayConfig>;
  validateConfig(config: GatewayConfig): Promise<ValidationResult>;
  migrateConfig(source: MCPConfig): Promise<GatewayConfig>;
  rollbackConfig(): Promise<void>;
  saveConfig(config: GatewayConfig): Promise<void>;
  getConfigPath(): string;
}

export interface GatewayOrchestrator {
  startGateway(config: GatewayConfig): Promise<OperationResult>;
  stopGateway(): Promise<OperationResult>;
  restartGateway(): Promise<OperationResult>;
  getGatewayStatus(): Promise<GatewayStatus>;
  updateGatewayConfig(config: GatewayConfig): Promise<OperationResult>;
  checkDockerRequirements(): Promise<ValidationResult>;
}

export interface ServerManager {
  addServer(serverConfig: ServerConfig): Promise<OperationResult>;
  removeServer(serverId: string): Promise<OperationResult>;
  updateServer(serverId: string, config: ServerConfig): Promise<OperationResult>;
  getServerStatus(serverId: string): Promise<ServerStatus>;
  listServers(): Promise<ServerConfig[]>;
  restartServer(serverId: string): Promise<OperationResult>;
}

export interface MonitoringService {
  getMetrics(): Promise<GatewayMetrics>;
  getLogs(filter?: LogFilter): Promise<LogEntry[]>;
  performHealthCheck(): Promise<HealthStatus>;
  generateDiagnosticReport(): Promise<DiagnosticReport>;
  startMonitoring(): Promise<void>;
  stopMonitoring(): Promise<void>;
}

// ============================================================================
// Event Types
// ============================================================================

export interface GatewayEvent {
  type: 'gateway_started' | 'gateway_stopped' | 'gateway_error' | 'config_changed';
  timestamp: Date;
  data?: Record<string, any>;
}

export interface ServerEvent {
  type: 'server_started' | 'server_stopped' | 'server_error' | 'server_added' | 'server_removed';
  serverId: string;
  timestamp: Date;
  data?: Record<string, any>;
}

export type EventHandler<T> = (event: T) => void | Promise<void>;

// ============================================================================
// CLI Types
// ============================================================================

export interface CLIConfig {
  verbose: boolean;
  configPath?: string;
  logLevel: GatewayConfig['gateway']['logLevel'];
}

export interface CLICommand {
  name: string;
  description: string;
  execute(args: any, config: CLIConfig): Promise<void>;
}
