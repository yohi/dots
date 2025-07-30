/**
 * Logs Command
 * Shows Docker MCP Gateway logs with filtering and follow capabilities
 */

import chalk from 'chalk';
import {
  CLICommand,
  CLIConfig,
  MonitoringService,
  LogEntry,
  LogFilter
} from '../../types/interfaces.js';

interface LogsOptions {
  follow?: boolean;
  tail?: string;
  server?: string;
  level?: string;
  since?: string;
  until?: string;
  json?: boolean;
}

export class LogsCommand implements CLICommand {
  name = 'logs';
  description = 'Docker MCP Gateway のログを表示';

  constructor(
    private monitoringService: MonitoringService
  ) { }

  async execute(options: LogsOptions, cliConfig: CLIConfig): Promise<void> {
    if (options.follow) {
      await this.followLogs(options);
    } else {
      await this.showLogs(options);
    }
  }

  private async showLogs(options: LogsOptions): Promise<void> {
    try {
      const filter = this.buildLogFilter(options);
      const logs = await this.monitoringService.getLogs(filter);

      if (options.json) {
        console.log(JSON.stringify(logs, null, 2));
        return;
      }

      this.displayLogsFormatted(logs, options);

    } catch (error) {
      if (options.json) {
        console.log(JSON.stringify({
          error: error instanceof Error ? error.message : String(error)
        }, null, 2));
      } else {
        throw new Error(`Failed to get logs: ${error instanceof Error ? error.message : String(error)}`);
      }
    }
  }

  private async followLogs(options: LogsOptions): Promise<void> {
    console.log(chalk.blue('📋 Following Docker MCP Gateway logs (Press Ctrl+C to stop)'));

    if (options.server) {
      console.log(chalk.gray(`Filtering by server: ${options.server}`));
    }

    if (options.level) {
      console.log(chalk.gray(`Filtering by level: ${options.level}`));
    }

    console.log(chalk.gray('=====================================\n'));

    let lastLogCount = 0;

    const followInterval = setInterval(async () => {
      try {
        const filter = this.buildLogFilter(options);
        const logs = await this.monitoringService.getLogs(filter);

        // Show only new logs
        const newLogs = logs.slice(lastLogCount);
        if (newLogs.length > 0) {
          this.displayLogsFormatted(newLogs, options, false);
          lastLogCount = logs.length;
        }

      } catch (error) {
        if (!options.json) {
          console.error(chalk.red(`Error getting logs: ${error instanceof Error ? error.message : String(error)}`));
        }
      }
    }, 2000); // Check for new logs every 2 seconds

    // Handle Ctrl+C gracefully
    process.on('SIGINT', () => {
      clearInterval(followInterval);
      if (!options.json) {
        console.log(chalk.yellow('\n\n👋 Stopped following logs'));
      }
      process.exit(0);
    });

    // Show initial logs
    await this.showLogs(options);
  }

  private buildLogFilter(options: LogsOptions): LogFilter {
    const filter: LogFilter = {};

    // Apply tail limit
    if (options.tail) {
      const limit = parseInt(options.tail, 10);
      if (!isNaN(limit) && limit > 0) {
        filter.limit = limit;
      }
    } else {
      filter.limit = 100; // Default limit
    }

    // Apply server filter
    if (options.server) {
      filter.serverId = options.server;
    }

    // Apply level filter
    if (options.level) {
      const validLevels = ['debug', 'info', 'warn', 'error'];
      if (validLevels.includes(options.level)) {
        filter.level = options.level as LogEntry['level'];
      }
    }

    // Apply time range filters
    if (options.since) {
      filter.startTime = this.parseTimeString(options.since);
    }

    if (options.until) {
      filter.endTime = this.parseTimeString(options.until);
    }

    return filter;
  }

  private parseTimeString(timeStr: string): Date | undefined {
    try {
      // Try parsing as ISO string first
      let date = new Date(timeStr);
      if (!isNaN(date.getTime())) {
        return date;
      }

      // Try parsing relative time (e.g., "1h", "30m", "2d")
      const relativeMatch = timeStr.match(/^(\d+)([smhd])$/);
      if (relativeMatch) {
        const value = parseInt(relativeMatch[1], 10);
        const unit = relativeMatch[2];
        const now = Date.now();

        switch (unit) {
          case 's':
            return new Date(now - value * 1000);
          case 'm':
            return new Date(now - value * 60 * 1000);
          case 'h':
            return new Date(now - value * 60 * 60 * 1000);
          case 'd':
            return new Date(now - value * 24 * 60 * 60 * 1000);
        }
      }

      return undefined;
    } catch {
      return undefined;
    }
  }

  private displayLogsFormatted(logs: LogEntry[], options: LogsOptions, showHeader: boolean = true): void {
    if (logs.length === 0) {
      if (showHeader) {
        console.log(chalk.yellow('No logs found matching the specified criteria'));
      }
      return;
    }

    if (showHeader) {
      console.log(chalk.blue('📋 Docker MCP Gateway Logs'));
      console.log(chalk.gray('=============================\n'));
    }

    for (const log of logs) {
      this.displayLogEntry(log);
    }

    if (showHeader) {
      console.log(chalk.gray(`\nShowing ${logs.length} log entries`));
      console.log(chalk.cyan('\n💡 Tips:'));
      console.log(chalk.gray('  • Use --follow to watch logs in real-time'));
      console.log(chalk.gray('  • Use --server <id> to filter by specific server'));
      console.log(chalk.gray('  • Use --level <level> to filter by log level'));
      console.log(chalk.gray('  • Use --since <time> for time-based filtering'));
    }
  }

  private displayLogEntry(log: LogEntry): void {
    const timestamp = log.timestamp.toISOString();
    const level = this.formatLogLevel(log.level);
    const source = this.formatSource(log.source, log.serverId);

    console.log(`${chalk.gray(timestamp)} ${level} ${source} ${log.message}`);

    // Display metadata if present
    if (log.metadata && Object.keys(log.metadata).length > 0) {
      const metadataStr = JSON.stringify(log.metadata, null, 2);
      const indentedMetadata = metadataStr.split('\n')
        .map(line => `  ${chalk.gray(line)}`)
        .join('\n');
      console.log(indentedMetadata);
    }
  }

  private formatLogLevel(level: LogEntry['level']): string {
    switch (level) {
      case 'debug':
        return chalk.gray('[DEBUG]');
      case 'info':
        return chalk.cyan('[INFO] ');
      case 'warn':
        return chalk.yellow('[WARN] ');
      case 'error':
        return chalk.red('[ERROR]');
      default:
        return chalk.white(`[${level.toUpperCase()}]`);
    }
  }

  private formatSource(source: LogEntry['source'], serverId?: string): string {
    if (source === 'gateway') {
      return chalk.blue('[Gateway]');
    } else if (source === 'server' && serverId) {
      return chalk.green(`[${serverId}]`);
    } else {
      return chalk.white(`[${source}]`);
    }
  }
}
