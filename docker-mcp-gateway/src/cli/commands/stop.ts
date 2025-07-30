/**
 * Stop Command
 * Stops the Docker MCP Gateway
 */

import chalk from 'chalk';
import {
  CLICommand,
  CLIConfig,
  GatewayOrchestrator
} from '../../types/interfaces.js';

interface StopOptions {
  force?: boolean;
}

export class StopCommand implements CLICommand {
  name = 'stop';
  description = 'Docker MCP Gateway を停止';

  constructor(
    private orchestrator: GatewayOrchestrator
  ) { }

  async execute(options: StopOptions, cliConfig: CLIConfig): Promise<void> {
    console.log(chalk.blue('🛑 Docker MCP Gateway を停止中'));
    console.log(chalk.gray('==================================\n'));

    try {
      // Check current status
      const status = await this.orchestrator.getGatewayStatus();

      if (status.status === 'stopped') {
        console.log(chalk.yellow('⚠️  Gateway is already stopped'));
        return;
      }

      if (status.status === 'error') {
        console.log(chalk.yellow('⚠️  Gateway is in error state, attempting to clean up...'));
      } else {
        console.log(chalk.cyan(`Gateway is currently ${status.status}`));
        console.log(chalk.gray(`Uptime: ${this.formatUptime(status.uptime)}`));
        console.log(chalk.gray(`Configured servers: ${status.serversCount}\n`));
      }

      // Perform stop operation
      await this.stopGateway(options.force || false);

      console.log(chalk.green('✅ Docker MCP Gateway stopped successfully!'));

      console.log(chalk.cyan('\n🔧 Next steps:'));
      console.log(chalk.gray('  • Start again: docker-mcp-gateway start'));
      console.log(chalk.gray('  • Check status: docker-mcp-gateway status'));

    } catch (error) {
      throw new Error(`Failed to stop gateway: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async stopGateway(force: boolean): Promise<void> {
    console.log(chalk.blue('🔄 Stopping gateway...'));

    if (force) {
      console.log(chalk.yellow('⚡ Force mode enabled - immediate shutdown'));
    } else {
      console.log(chalk.gray('🕒 Graceful shutdown (30s timeout)'));
    }

    const result = await this.orchestrator.stopGateway();

    if (!result.success) {
      throw new Error(result.error || 'Unknown error occurred during stop');
    }

    console.log(chalk.green('✅ Gateway stopped successfully'));
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
