/**
 * Status Command
 * Shows Docker MCP Gateway status and health information
 */

import chalk from 'chalk';
import {
  CLICommand,
  CLIConfig,
  GatewayOrchestrator,
  GatewayStatus
} from '../../types/interfaces.js';

interface StatusOptions {
  json?: boolean;
  watch?: boolean;
}

export class StatusCommand implements CLICommand {
  name = 'status';
  description = 'Docker MCP Gateway のステータスを表示';

  constructor(
    private orchestrator: GatewayOrchestrator
  ) { }

  async execute(options: StatusOptions, cliConfig: CLIConfig): Promise<void> {
    if (options.watch) {
      await this.watchStatus(options.json || false);
    } else {
      await this.showStatus(options.json || false);
    }
  }

  private async showStatus(jsonOutput: boolean): Promise<void> {
    try {
      const status = await this.orchestrator.getGatewayStatus();

      if (jsonOutput) {
        console.log(JSON.stringify(status, null, 2));
        return;
      }

      this.displayStatusFormatted(status);

    } catch (error) {
      if (jsonOutput) {
        console.log(JSON.stringify({
          error: error instanceof Error ? error.message : String(error)
        }, null, 2));
      } else {
        throw new Error(`Failed to get status: ${error instanceof Error ? error.message : String(error)}`);
      }
    }
  }

  private async watchStatus(jsonOutput: boolean): Promise<void> {
    console.log(chalk.blue('👀 Watching gateway status (Press Ctrl+C to stop)'));
    console.log(chalk.gray('Refreshing every 5 seconds...\n'));

    const watchInterval = setInterval(async () => {
      try {
        if (!jsonOutput) {
          // Clear screen and move cursor to top
          process.stdout.write('\x1B[2J\x1B[0f');
          console.log(chalk.blue('👀 Docker MCP Gateway Status (Live)'));
          console.log(chalk.gray(`Last updated: ${new Date().toLocaleTimeString()}`));
          console.log(chalk.gray('=====================================\n'));
        }

        await this.showStatus(jsonOutput);

        if (!jsonOutput) {
          console.log(chalk.gray('\nPress Ctrl+C to stop watching'));
        }

      } catch (error) {
        if (!jsonOutput) {
          console.error(chalk.red(`Error getting status: ${error instanceof Error ? error.message : String(error)}`));
        }
      }
    }, 5000);

    // Handle Ctrl+C gracefully
    process.on('SIGINT', () => {
      clearInterval(watchInterval);
      if (!jsonOutput) {
        console.log(chalk.yellow('\n\n👋 Stopped watching'));
      }
      process.exit(0);
    });

    // Show initial status
    await this.showStatus(jsonOutput);
  }

  private displayStatusFormatted(status: GatewayStatus): void {
    console.log(chalk.blue('📊 Docker MCP Gateway Status'));
    console.log(chalk.gray('=============================\n'));

    // Gateway Status
    const statusColor = this.getStatusColor(status.status);
    const statusIcon = this.getStatusIcon(status.status);

    console.log(chalk.cyan('Gateway:'));
    console.log(`  ${statusIcon} Status: ${statusColor(status.status.toUpperCase())}`);
    console.log(chalk.gray(`  🕒 Uptime: ${this.formatUptime(status.uptime)}`));
    console.log(chalk.gray(`  📦 Version: ${status.version}`));
    console.log(chalk.gray(`  🖥️  Servers: ${status.serversCount} configured`));

    if (status.lastRestart) {
      console.log(chalk.gray(`  🔄 Last Restart: ${status.lastRestart.toLocaleString()}`));
    }
    console.log();

    // Connection Information
    if (status.status === 'running') {
      console.log(chalk.cyan('Connection:'));
      console.log(chalk.gray('  🌐 Gateway URL: http://localhost:8080'));
      console.log(chalk.gray('  ❤️  Health Check: http://localhost:8080/health'));
      console.log(chalk.gray('  🔌 MCP Endpoint: http://localhost:8080/mcp'));
      console.log();

      console.log(chalk.cyan('Quick Actions:'));
      console.log(chalk.gray('  • View logs: docker-mcp-gateway logs'));
      console.log(chalk.gray('  • Restart: docker-mcp-gateway restart'));
      console.log(chalk.gray('  • Stop: docker-mcp-gateway stop'));
    } else if (status.status === 'stopped') {
      console.log(chalk.cyan('Quick Actions:'));
      console.log(chalk.gray('  • Start: docker-mcp-gateway start'));
      console.log(chalk.gray('  • Check logs: docker-mcp-gateway logs'));
    } else if (status.status === 'error') {
      console.log(chalk.red('⚠️  Gateway is in error state'));
      console.log(chalk.cyan('Troubleshooting:'));
      console.log(chalk.gray('  • Check logs: docker-mcp-gateway logs'));
      console.log(chalk.gray('  • Restart: docker-mcp-gateway restart'));
      console.log(chalk.gray('  • Validate config: docker-mcp-gateway validate'));
    }

    // Health indicators
    this.displayHealthIndicators(status);
  }

  private displayHealthIndicators(status: GatewayStatus): void {
    console.log();
    console.log(chalk.cyan('Health Indicators:'));

    if (status.status === 'running') {
      console.log(chalk.green('  ✅ Gateway is running'));

      if (status.serversCount > 0) {
        console.log(chalk.green(`  ✅ ${status.serversCount} server(s) configured`));
      } else {
        console.log(chalk.yellow('  ⚠️  No servers configured'));
      }

      if (status.uptime > 60000) { // More than 1 minute
        console.log(chalk.green('  ✅ Gateway is stable'));
      } else {
        console.log(chalk.yellow('  ⚠️  Gateway recently started'));
      }
    } else if (status.status === 'stopped') {
      console.log(chalk.gray('  ⏸️  Gateway is stopped'));
    } else {
      console.log(chalk.red('  ❌ Gateway has errors'));
    }

    // Performance indicators
    if (status.status === 'running') {
      console.log();
      console.log(chalk.cyan('Performance:'));

      const uptimeHours = status.uptime / (1000 * 60 * 60);
      if (uptimeHours > 24) {
        console.log(chalk.green('  ✅ Long-running (>24h)'));
      } else if (uptimeHours > 1) {
        console.log(chalk.green('  ✅ Stable (>1h)'));
      } else {
        console.log(chalk.yellow('  ⚠️  Recently started'));
      }
    }
  }

  private getStatusColor(status: string): (text: string) => string {
    switch (status) {
      case 'running':
        return chalk.green;
      case 'stopped':
        return chalk.gray;
      case 'error':
        return chalk.red;
      default:
        return chalk.yellow;
    }
  }

  private getStatusIcon(status: string): string {
    switch (status) {
      case 'running':
        return '🟢';
      case 'stopped':
        return '⚪';
      case 'error':
        return '🔴';
      default:
        return '🟡';
    }
  }

  private formatUptime(uptimeMs: number): string {
    if (uptimeMs < 1000) {
      return `${uptimeMs}ms`;
    }

    const seconds = Math.floor(uptimeMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days}d ${hours % 24}h ${minutes % 60}m`;
    } else if (hours > 0) {
      return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    } else {
      return `${seconds}s`;
    }
  }
}
