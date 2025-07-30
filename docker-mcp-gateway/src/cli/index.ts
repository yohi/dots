#!/usr/bin/env node

/**
 * Docker MCP Gateway CLI
 * コマンドラインインターフェースのメインエントリーポイント
 */

import { Command } from 'commander';
import chalk from 'chalk';
import { ConfigurationManagerImpl } from '../services/configuration-manager.js';
import { GatewayOrchestratorImpl } from '../services/gateway-orchestrator.js';
import { ServerManagerImpl } from '../services/server-manager.js';
import { MonitoringServiceImpl } from '../services/monitoring-service.js';
import { CLIConfig } from '../types/interfaces.js';

// CLI Commands
import { MigrateCommand } from './commands/migrate.js';
import { StartCommand } from './commands/start.js';
import { StopCommand } from './commands/stop.js';
import { StatusCommand } from './commands/status.js';
import { RestartCommand } from './commands/restart.js';
import { ValidateCommand } from './commands/validate.js';
import { LogsCommand } from './commands/logs.js';
import { HealthCommand } from './commands/health.js';

const program = new Command();

// グローバルCLI設定
let globalConfig: CLIConfig = {
  verbose: false,
  logLevel: 'info'
};

function setupGlobalOptions(command: Command): void {
  command
    .option('-v, --verbose', '詳細出力を有効化')
    .option('-c, --config <path>', '設定ファイルのパス')
    .option('--log-level <level>', 'ログレベル (debug, info, warn, error)', 'info')
    .hook('preAction', (thisCommand) => {
      const opts = thisCommand.opts();
      globalConfig = {
        verbose: opts.verbose || false,
        configPath: opts.config,
        logLevel: opts.logLevel || 'info'
      };

      if (globalConfig.verbose) {
        console.log(chalk.gray(`CLI Config: ${JSON.stringify(globalConfig, null, 2)}`));
      }
    });
}

async function main(): Promise<void> {
  const configManager = new ConfigurationManagerImpl();
  const orchestrator = new GatewayOrchestratorImpl();
  const serverManager = new ServerManagerImpl(configManager);
  const monitoringService = new MonitoringServiceImpl(configManager);

  // Setup program metadata
  program
    .name('docker-mcp-gateway')
    .description('Docker MCP Gateway management CLI')
    .version('1.0.0');

  setupGlobalOptions(program);

  // Register commands
  const migrateCmd = new MigrateCommand(configManager, orchestrator);
  const startCmd = new StartCommand(configManager, orchestrator);
  const stopCmd = new StopCommand(orchestrator);
  const statusCmd = new StatusCommand(orchestrator);
  const restartCmd = new RestartCommand(orchestrator);
  const validateCmd = new ValidateCommand(configManager);
  const logsCmd = new LogsCommand(monitoringService);
  const healthCmd = new HealthCommand(monitoringService, orchestrator);

  // Setup migrate command
  program
    .command('migrate')
    .description('Migrate existing MCP configuration to Docker MCP Gateway')
    .option('--dry-run', 'Show what would be migrated without making changes')
    .option('--backup', 'Create backup before migration', true)
    .action(async (options) => {
      try {
        await migrateCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Migration failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup start command
  program
    .command('start')
    .description('Start the Docker MCP Gateway')
    .option('--config-file <path>', 'Gateway configuration file path')
    .option('--port <port>', 'Gateway port (overrides config)', parseInt)
    .option('--detach', 'Run in detached mode', true)
    .action(async (options) => {
      try {
        await startCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Start failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup stop command
  program
    .command('stop')
    .description('Stop the Docker MCP Gateway')
    .option('--force', 'Force stop without graceful shutdown')
    .action(async (options) => {
      try {
        await stopCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Stop failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup restart command
  program
    .command('restart')
    .description('Restart the Docker MCP Gateway')
    .option('--force', 'Force restart without graceful shutdown')
    .action(async (options) => {
      try {
        await restartCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Restart failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup status command
  program
    .command('status')
    .description('Show Docker MCP Gateway status')
    .option('--json', 'Output status as JSON')
    .option('--watch', 'Watch status changes (refresh every 5 seconds)')
    .action(async (options) => {
      try {
        await statusCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Status check failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup validate command
  program
    .command('validate')
    .description('Validate Docker MCP Gateway configuration')
    .option('--config-file <path>', 'Configuration file to validate')
    .option('--fix', 'Attempt to fix validation issues automatically')
    .action(async (options) => {
      try {
        await validateCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Validation failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup logs command
  program
    .command('logs')
    .description('Show Docker MCP Gateway logs')
    .option('--follow', 'Follow log output')
    .option('--tail <lines>', 'Number of lines to show from the end', '100')
    .option('--server <server-id>', 'Show logs for specific server')
    .option('--level <level>', 'Filter by log level (debug, info, warn, error)')
    .option('--since <time>', 'Show logs since timestamp (e.g., "1h", "30m", "2024-01-01")')
    .option('--until <time>', 'Show logs until timestamp')
    .option('--json', 'Output logs as JSON')
    .action(async (options) => {
      try {
        await logsCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Logs command failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup health command
  program
    .command('health')
    .description('Check Docker MCP Gateway health')
    .option('--detailed', 'Show detailed health information')
    .option('--json', 'Output health status as JSON')
    .option('--continuous', 'Continuous health monitoring')
    .option('--interval <time>', 'Health check interval for continuous mode (default: 30s)')
    .action(async (options) => {
      try {
        await healthCmd.execute(options, globalConfig);
      } catch (error) {
        console.error(chalk.red(`Health check failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup server management commands
  const serverCmd = program
    .command('server')
    .description('Manage MCP servers');

  serverCmd
    .command('add <server-id>')
    .description('Add a new MCP server')
    .option('--image <image>', 'Docker image for the server')
    .option('--env <key=value...>', 'Environment variables')
    .option('--command <command...>', 'Command to run in the server')
    .option('--name <name>', 'Display name for the server')
    .option('--auto-restart', 'Enable auto-restart (default: true)', true)
    .action(async (serverId, options) => {
      try {
        if (!options.image) {
          throw new Error('Docker image is required (use --image option)');
        }

        const environment: Record<string, string> = {};
        if (options.env) {
          for (const envVar of options.env) {
            const [key, ...valueParts] = envVar.split('=');
            environment[key] = valueParts.join('=');
          }
        }
        environment.MCP_SERVER_ID = serverId;

        const serverConfig = {
          id: serverId,
          name: options.name || `MCP Server: ${serverId}`,
          image: options.image,
          command: options.command,
          environment,
          autoRestart: options.autoRestart !== false
        };

        const result = await serverManager.addServer(serverConfig);
        if (result.success) {
          console.log(chalk.green(`✅ Server "${serverId}" added successfully`));
        } else {
          console.error(chalk.red(`❌ Failed to add server: ${result.error}`));
          process.exit(1);
        }
      } catch (error) {
        console.error(chalk.red(`Server add failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  serverCmd
    .command('remove <server-id>')
    .description('Remove an MCP server')
    .option('--force', 'Force removal without confirmation')
    .action(async (serverId, options) => {
      try {
        if (!options.force) {
          const inquirer = await import('inquirer');
          const { confirmed } = await inquirer.default.prompt([
            {
              type: 'confirm',
              name: 'confirmed',
              message: `Are you sure you want to remove server "${serverId}"?`,
              default: false
            }
          ]);

          if (!confirmed) {
            console.log(chalk.yellow('Server removal cancelled'));
            return;
          }
        }

        const result = await serverManager.removeServer(serverId);
        if (result.success) {
          console.log(chalk.green(`✅ Server "${serverId}" removed successfully`));
        } else {
          console.error(chalk.red(`❌ Failed to remove server: ${result.error}`));
          process.exit(1);
        }
      } catch (error) {
        console.error(chalk.red(`Server remove failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  serverCmd
    .command('list')
    .description('List all MCP servers')
    .option('--json', 'Output as JSON')
    .action(async (options) => {
      try {
        const servers = await serverManager.listServers();

        if (options.json) {
          console.log(JSON.stringify(servers, null, 2));
          return;
        }

        if (servers.length === 0) {
          console.log(chalk.yellow('No servers configured'));
          return;
        }

        console.log(chalk.blue('📦 Configured MCP Servers'));
        console.log(chalk.gray('========================\n'));

        for (const server of servers) {
          console.log(chalk.cyan(`🔹 ${server.id}`));
          console.log(chalk.gray(`   Name: ${server.name}`));
          console.log(chalk.gray(`   Image: ${server.image}`));
          if (server.command) {
            console.log(chalk.gray(`   Command: ${server.command.join(' ')}`));
          }
          console.log(chalk.gray(`   Environment: ${Object.keys(server.environment).length} variables`));
          console.log(chalk.gray(`   Auto Restart: ${server.autoRestart ? 'Yes' : 'No'}`));
          console.log();
        }
      } catch (error) {
        console.error(chalk.red(`Server list failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  // Setup configuration commands
  const configCmd = program
    .command('config')
    .description('Configuration management');

  configCmd
    .command('show')
    .description('Show current configuration')
    .option('--format <format>', 'Output format (yaml, json)', 'yaml')
    .action(async (options) => {
      try {
        const configPath = configManager.getConfigPath();
        const fs = await import('fs-extra');

        if (!await fs.pathExists(configPath)) {
          console.log(chalk.yellow('No configuration file found'));
          console.log(chalk.gray(`Expected location: ${configPath}`));
          console.log(chalk.gray('Run "docker-mcp-gateway migrate" to create initial configuration'));
          return;
        }

        const configContent = await fs.readFile(configPath, 'utf-8');

        if (options.format === 'json') {
          const yaml = await import('yaml');
          const config = yaml.parse(configContent);
          console.log(JSON.stringify(config, null, 2));
        } else {
          console.log(configContent);
        }
      } catch (error) {
        console.error(chalk.red(`Config show failed: ${error instanceof Error ? error.message : String(error)}`));
        process.exit(1);
      }
    });

  configCmd
    .command('edit')
    .description('Edit configuration interactively')
    .action(async () => {
      console.log(chalk.yellow('Interactive configuration editing coming soon...'));
      console.log(chalk.gray('For now, manually edit the configuration file:'));
      console.log(chalk.gray(`  ${configManager.getConfigPath()}`));
    });

  // Error handling for unknown commands
  program.on('command:*', () => {
    console.error(chalk.red(`Unknown command: ${program.args.join(' ')}`));
    console.log(chalk.gray('See --help for available commands'));
    process.exit(1);
  });

  // Handle no command provided
  if (process.argv.length <= 2) {
    program.outputHelp();
    process.exit(0);
  }

  // Parse arguments and execute
  await program.parseAsync(process.argv);
}

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  console.error(chalk.red('Uncaught exception:'), error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error(chalk.red('Unhandled rejection at:'), promise, 'reason:', reason);
  process.exit(1);
});

// Run CLI
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(chalk.red('CLI execution failed:'), error);
    process.exit(1);
  });
}
