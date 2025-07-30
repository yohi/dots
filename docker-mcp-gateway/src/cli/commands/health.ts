/**
 * Health Command
 * Performs comprehensive health checks on Docker MCP Gateway and servers
 */

import chalk from 'chalk';
import {
  CLICommand,
  CLIConfig,
  MonitoringService,
  GatewayOrchestrator,
  HealthStatus
} from '../../types/interfaces.js';

interface HealthOptions {
  detailed?: boolean;
  json?: boolean;
  continuous?: boolean;
  interval?: string;
}

export class HealthCommand implements CLICommand {
  name = 'health';
  description = 'Check Docker MCP Gateway health';

  constructor(
    private monitoringService: MonitoringService,
    private orchestrator: GatewayOrchestrator
  ) { }

  async execute(options: HealthOptions, cliConfig: CLIConfig): Promise<void> {
    if (options.continuous) {
      await this.continuousHealthCheck(options);
    } else {
      await this.performSingleHealthCheck(options);
    }
  }

  private async performSingleHealthCheck(options: HealthOptions): Promise<void> {
    try {
      const healthStatus = await this.monitoringService.performHealthCheck();

      if (options.json) {
        console.log(JSON.stringify(healthStatus, null, 2));
        return;
      }

      this.displayHealthStatusFormatted(healthStatus, options.detailed || false);

      // Exit with appropriate code
      if (healthStatus.overall === 'unhealthy') {
        process.exit(1);
      } else if (healthStatus.overall === 'degraded') {
        process.exit(2);
      }

    } catch (error) {
      if (options.json) {
        console.log(JSON.stringify({
          error: error instanceof Error ? error.message : String(error),
          overall: 'unhealthy'
        }, null, 2));
      } else {
        throw new Error(`Health check failed: ${error instanceof Error ? error.message : String(error)}`);
      }
      process.exit(1);
    }
  }

  private async continuousHealthCheck(options: HealthOptions): Promise<void> {
    const interval = this.parseInterval(options.interval || '30s');

    console.log(chalk.blue('🔍 Continuous health monitoring (Press Ctrl+C to stop)'));
    console.log(chalk.gray(`Checking every ${this.formatInterval(interval)}`));
    console.log(chalk.gray('=====================================\n'));

    let checkCount = 0;

    const healthInterval = setInterval(async () => {
      checkCount++;

      try {
        if (!options.json) {
          console.log(chalk.cyan(`\n--- Health Check #${checkCount} at ${new Date().toLocaleTimeString()} ---`));
        }

        const healthStatus = await this.monitoringService.performHealthCheck();

        if (options.json) {
          console.log(JSON.stringify({
            checkNumber: checkCount,
            timestamp: new Date().toISOString(),
            ...healthStatus
          }, null, 2));
        } else {
          this.displayHealthStatusFormatted(healthStatus, options.detailed || false, false);
        }

      } catch (error) {
        if (options.json) {
          console.log(JSON.stringify({
            checkNumber: checkCount,
            timestamp: new Date().toISOString(),
            error: error instanceof Error ? error.message : String(error),
            overall: 'unhealthy'
          }, null, 2));
        } else {
          console.error(chalk.red(`Health check failed: ${error instanceof Error ? error.message : String(error)}`));
        }
      }
    }, interval);

    // Handle Ctrl+C gracefully
    process.on('SIGINT', () => {
      clearInterval(healthInterval);
      if (!options.json) {
        console.log(chalk.yellow(`\n\n👋 Stopped health monitoring after ${checkCount} checks`));
      }
      process.exit(0);
    });

    // Perform initial health check
    await this.performSingleHealthCheck({
      ...options,
      continuous: false
    });
  }

  private displayHealthStatusFormatted(healthStatus: HealthStatus, detailed: boolean, showHeader: boolean = true): void {
    if (showHeader) {
      console.log(chalk.blue('🏥 Docker MCP Gateway Health Check'));
      console.log(chalk.gray('===================================\n'));
    }

    // Overall status
    const overallIcon = this.getStatusIcon(healthStatus.overall);
    const overallColor = this.getStatusColor(healthStatus.overall);

    console.log(chalk.cyan('Overall Status:'));
    console.log(`  ${overallIcon} ${overallColor(healthStatus.overall.toUpperCase())}`);
    console.log();

    // Gateway health
    console.log(chalk.cyan('Gateway Health:'));
    const gatewayIcon = this.getStatusIcon(healthStatus.gateway.status);
    const gatewayColor = this.getStatusColor(healthStatus.gateway.status);

    console.log(`  ${gatewayIcon} Status: ${gatewayColor(healthStatus.gateway.status.toUpperCase())}`);
    console.log(chalk.gray(`  📋 Details: ${healthStatus.gateway.details}`));
    console.log();

    // Server health
    const serverEntries = Object.entries(healthStatus.servers);
    if (serverEntries.length > 0) {
      console.log(chalk.cyan('Server Health:'));

      for (const [serverId, serverHealth] of serverEntries) {
        const serverIcon = this.getStatusIcon(serverHealth.status);
        const serverColor = this.getStatusColor(serverHealth.status);

        console.log(`  ${serverIcon} ${serverId}: ${serverColor(serverHealth.status.toUpperCase())}`);
        if (detailed || serverHealth.status === 'unhealthy') {
          console.log(chalk.gray(`    📋 ${serverHealth.details}`));
        }
      }
      console.log();
    } else {
      console.log(chalk.yellow('No servers configured\n'));
    }

    // Health summary
    this.displayHealthSummary(healthStatus);

    // Recommendations
    if (healthStatus.overall !== 'healthy') {
      this.displayHealthRecommendations(healthStatus);
    }

    // Detailed information
    if (detailed) {
      this.displayDetailedHealthInfo(healthStatus);
    }
  }

  private displayHealthSummary(healthStatus: HealthStatus): void {
    console.log(chalk.cyan('Health Summary:'));

    const serverStats = Object.values(healthStatus.servers).reduce(
      (stats, server) => {
        stats[server.status] = (stats[server.status] || 0) + 1;
        return stats;
      },
      {} as Record<string, number>
    );

    console.log(chalk.gray(`  • Gateway: ${healthStatus.gateway.status}`));

    if (Object.keys(serverStats).length > 0) {
      const healthy = serverStats.healthy || 0;
      const unhealthy = serverStats.unhealthy || 0;
      const total = healthy + unhealthy;

      console.log(chalk.gray(`  • Servers: ${healthy}/${total} healthy`));

      if (unhealthy > 0) {
        console.log(chalk.yellow(`  • Unhealthy servers: ${unhealthy}`));
      }
    }
    console.log();
  }

  private displayHealthRecommendations(healthStatus: HealthStatus): void {
    console.log(chalk.cyan('🔧 Recommendations:'));

    if (healthStatus.gateway.status === 'unhealthy') {
      console.log(chalk.gray('  • Check gateway container status'));
      console.log(chalk.gray('  • Restart gateway: docker-mcp-gateway restart'));
      console.log(chalk.gray('  • Check Docker daemon status'));
      console.log(chalk.gray('  • Review gateway logs: docker-mcp-gateway logs'));
    }

    const unhealthyServers = Object.entries(healthStatus.servers)
      .filter(([_, server]) => server.status === 'unhealthy');

    if (unhealthyServers.length > 0) {
      console.log(chalk.gray('  • Check server configurations'));
      console.log(chalk.gray('  • Review server-specific logs'));
      console.log(chalk.gray('  • Validate server images and commands'));

      for (const [serverId] of unhealthyServers) {
        console.log(chalk.gray(`  • Check server "${serverId}" configuration`));
      }
    }

    console.log(chalk.gray('  • Run diagnostic report: docker-mcp-gateway health --detailed'));
    console.log();
  }

  private displayDetailedHealthInfo(healthStatus: HealthStatus): void {
    console.log(chalk.cyan('🔍 Detailed Health Information:'));

    // Gateway details
    console.log(chalk.yellow('Gateway Details:'));
    console.log(chalk.gray(`  Status: ${healthStatus.gateway.status}`));
    console.log(chalk.gray(`  Details: ${healthStatus.gateway.details}`));
    console.log();

    // Server details
    if (Object.keys(healthStatus.servers).length > 0) {
      console.log(chalk.yellow('Server Details:'));

      for (const [serverId, serverHealth] of Object.entries(healthStatus.servers)) {
        console.log(chalk.gray(`  ${serverId}:`));
        console.log(chalk.gray(`    Status: ${serverHealth.status}`));
        console.log(chalk.gray(`    Details: ${serverHealth.details}`));
      }
      console.log();
    }

    // Troubleshooting tips
    console.log(chalk.cyan('💡 Troubleshooting Tips:'));
    console.log(chalk.gray('  • Use "docker-mcp-gateway status" for current gateway status'));
    console.log(chalk.gray('  • Use "docker-mcp-gateway logs" to view recent logs'));
    console.log(chalk.gray('  • Use "docker-mcp-gateway validate" to check configuration'));
    console.log(chalk.gray('  • Use "docker ps" to check container status directly'));
  }

  private getStatusIcon(status: string): string {
    switch (status) {
      case 'healthy':
        return '✅';
      case 'unhealthy':
        return '❌';
      case 'degraded':
        return '⚠️';
      default:
        return '❓';
    }
  }

  private getStatusColor(status: string): (text: string) => string {
    switch (status) {
      case 'healthy':
        return chalk.green;
      case 'unhealthy':
        return chalk.red;
      case 'degraded':
        return chalk.yellow;
      default:
        return chalk.gray;
    }
  }

  private parseInterval(intervalStr: string): number {
    const match = intervalStr.match(/^(\d+)([smh]?)$/);
    if (!match) {
      return 30000; // Default 30 seconds
    }

    const value = parseInt(match[1], 10);
    const unit = match[2] || 's';

    switch (unit) {
      case 's':
        return value * 1000;
      case 'm':
        return value * 60 * 1000;
      case 'h':
        return value * 60 * 60 * 1000;
      default:
        return value * 1000;
    }
  }

  private formatInterval(intervalMs: number): string {
    if (intervalMs < 60000) {
      return `${intervalMs / 1000}s`;
    } else if (intervalMs < 3600000) {
      return `${intervalMs / 60000}m`;
    } else {
      return `${intervalMs / 3600000}h`;
    }
  }
}
