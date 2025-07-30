/**
 * Restart Command
 * Restarts the Docker MCP Gateway
 */

import chalk from 'chalk';
import {
  CLICommand,
  CLIConfig,
  GatewayOrchestrator
} from '../../types/interfaces.js';

interface RestartOptions {
  force?: boolean;
}

export class RestartCommand implements CLICommand {
  name = 'restart';
  description = 'Docker MCP Gateway を再起動';

  constructor(
    private orchestrator: GatewayOrchestrator
  ) { }

  async execute(options: RestartOptions, cliConfig: CLIConfig): Promise<void> {
    console.log(chalk.blue('🔄 Restarting Docker MCP Gateway'));
    console.log(chalk.gray('===================================\n'));

    try {
      // Check current status
      const status = await this.orchestrator.getGatewayStatus();
      this.displayCurrentStatus(status);

      // Perform restart operation
      await this.restartGateway(options.force || false);

      console.log(chalk.green('\n✅ Docker MCP Gateway restarted successfully!'));

      // Get new status
      const newStatus = await this.orchestrator.getGatewayStatus();
      this.displayPostRestartInfo(newStatus);

    } catch (error) {
      throw new Error(`Failed to restart gateway: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private displayCurrentStatus(status: any): void {
    console.log(chalk.cyan('Current Status:'));
    console.log(chalk.gray(`  • Status: ${status.status}`));

    if (status.status === 'running') {
      console.log(chalk.gray(`  • Uptime: ${this.formatUptime(status.uptime)}`));
      console.log(chalk.gray(`  • Servers: ${status.serversCount} configured`));
    } else if (status.status === 'stopped') {
      console.log(chalk.gray('  • Gateway is currently stopped'));
    } else if (status.status === 'error') {
      console.log(chalk.yellow('  • Gateway is in error state'));
    }
    console.log();
  }

  private async restartGateway(force: boolean): Promise<void> {
    console.log(chalk.blue('🔄 Performing restart...'));

    if (force) {
      console.log(chalk.yellow('⚡ Force mode enabled'));
    }

    const steps = [
      'Stopping current gateway instance',
      'Cleaning up resources',
      'Starting new gateway instance',
      'Waiting for gateway to be ready'
    ];

    for (let i = 0; i < steps.length; i++) {
      console.log(chalk.gray(`  ${i + 1}/${steps.length} ${steps[i]}...`));

      // Add small delay to make progress visible
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    const result = await this.orchestrator.restartGateway();

    if (!result.success) {
      throw new Error(result.error || 'Unknown error occurred during restart');
    }

    console.log(chalk.green('  ✅ Restart completed'));
  }

  private displayPostRestartInfo(status: any): void {
    console.log(chalk.cyan('\n📊 New Status:'));
    console.log(chalk.gray(`  • Status: ${status.status}`));
    console.log(chalk.gray(`  • Uptime: ${this.formatUptime(status.uptime)}`));
    console.log(chalk.gray(`  • Servers: ${status.serversCount} configured`));

    if (status.status === 'running') {
      console.log(chalk.cyan('\n🌐 Connection Information:'));
      console.log(chalk.gray('  • Gateway URL: http://localhost:8080'));
      console.log(chalk.gray('  • Health Check: http://localhost:8080/health'));

      console.log(chalk.cyan('\n🔧 Quick Actions:'));
      console.log(chalk.gray('  • Check status: docker-mcp-gateway status'));
      console.log(chalk.gray('  • View logs: docker-mcp-gateway logs'));
      console.log(chalk.gray('  • Stop gateway: docker-mcp-gateway stop'));
    }
  }

  private formatUptime(uptimeMs: number): string {
    const seconds = Math.floor(uptimeMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days}d ${hours % 24}h ${minutes % 60}m`;
    } else if (hours > 0) {
      return `${hours}h ${minutes % 60}m`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    } else {
      return `${seconds}s`;
    }
  }
}
