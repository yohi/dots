/**
 * Start コマンド
 * Docker MCP Gateway を開始します
 */

import chalk from 'chalk';
import fs from 'fs-extra';
import yaml from 'yaml';
import {
  CLICommand,
  CLIConfig,
  ConfigurationManager,
  GatewayOrchestrator,
  GatewayConfig
} from '../../types/interfaces.js';

interface StartOptions {
  configFile?: string;
  port?: number;
  detach?: boolean;
}

export class StartCommand implements CLICommand {
  name = 'start';
  description = 'Docker MCP Gateway を開始';

  constructor(
    private configManager: ConfigurationManager,
    private orchestrator: GatewayOrchestrator
  ) { }

  async execute(options: StartOptions, cliConfig: CLIConfig): Promise<void> {
    console.log(chalk.blue('🚀 Starting Docker MCP Gateway'));
    console.log(chalk.gray('=================================\n'));

    try {
      // Step 1: Load configuration
      const gatewayConfig = await this.loadGatewayConfiguration(options.configFile);

      // Step 2: Override port if specified
      if (options.port) {
        gatewayConfig.gateway.port = options.port;
        console.log(chalk.cyan(`Port overridden to: ${options.port}`));
      }

      // Step 3: Validate configuration
      await this.validateConfiguration(gatewayConfig);

      // Step 4: Check if gateway is already running
      await this.checkExistingGateway();

      // Step 5: Display startup plan
      this.displayStartupPlan(gatewayConfig);

      // Step 6: Start the gateway
      await this.startGateway(gatewayConfig, options.detach !== false);

      console.log(chalk.green('\n✅ Docker MCP Gateway started successfully!'));
      this.displayPostStartupInfo(gatewayConfig);

    } catch (error) {
      throw new Error(`Failed to start gateway: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async loadGatewayConfiguration(configFile?: string): Promise<GatewayConfig> {
    console.log(chalk.blue('📖 Loading gateway configuration...'));

    try {
      let configPath: string;

      if (configFile) {
        configPath = configFile;
        console.log(chalk.gray(`Using specified config file: ${configPath}`));
      } else {
        configPath = this.configManager.getConfigPath();
        console.log(chalk.gray(`Using default config file: ${configPath}`));
      }

      if (!await fs.pathExists(configPath)) {
        throw new Error(
          `Gateway configuration not found at: ${configPath}\n` +
          'Run "docker-mcp-gateway migrate" to create initial configuration'
        );
      }

      const configContent = await fs.readFile(configPath, 'utf-8');
      const gatewayConfig = yaml.parse(configContent) as GatewayConfig;

      const serverCount = Object.keys(gatewayConfig.servers).length;
      console.log(chalk.green(`✅ Configuration loaded (${serverCount} servers configured)\n`));

      return gatewayConfig;

    } catch (error) {
      throw new Error(`Failed to load configuration: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async validateConfiguration(config: GatewayConfig): Promise<void> {
    console.log(chalk.blue('🔍 Validating configuration...'));

    const validation = await this.configManager.validateConfig(config);

    if (!validation.isValid) {
      console.log(chalk.red('❌ Configuration validation failed:'));
      for (const error of validation.errors) {
        console.log(chalk.red(`   • ${error.field}: ${error.message}`));
      }
      throw new Error('Configuration validation failed');
    }

    if (validation.warnings.length > 0) {
      console.log(chalk.yellow('⚠️  Configuration warnings:'));
      for (const warning of validation.warnings) {
        console.log(chalk.yellow(`   • ${warning}`));
      }
    }

    console.log(chalk.green('✅ Configuration is valid\n'));
  }

  private async checkExistingGateway(): Promise<void> {
    console.log(chalk.blue('🔍 Checking for existing gateway...'));

    const status = await this.orchestrator.getGatewayStatus();

    if (status.status === 'running') {
      throw new Error(
        `Gateway is already running (uptime: ${Math.round(status.uptime / 1000)}s)\n` +
        'Use "docker-mcp-gateway restart" to restart or "docker-mcp-gateway stop" to stop'
      );
    }

    if (status.status === 'error') {
      console.log(chalk.yellow('⚠️  Gateway container exists but has errors'));
      console.log(chalk.gray('   Will attempt to clean up and restart\n'));
    } else {
      console.log(chalk.green('✅ No existing gateway found\n'));
    }
  }

  private displayStartupPlan(config: GatewayConfig): void {
    console.log(chalk.blue('📋 Startup Plan'));
    console.log(chalk.gray('===============\n'));

    console.log(chalk.cyan('Gateway Settings:'));
    console.log(chalk.gray(`  • Host: ${config.gateway.host}`));
    console.log(chalk.gray(`  • Port: ${config.gateway.port}`));
    console.log(chalk.gray(`  • Log Level: ${config.gateway.logLevel}`));
    console.log(chalk.gray(`  • Network: ${config.network.name}\n`));

    console.log(chalk.cyan('MCP Servers to Deploy:'));
    const servers = Object.entries(config.servers);
    if (servers.length === 0) {
      console.log(chalk.yellow('  ⚠️  No servers configured'));
    } else {
      for (const [serverId, serverConfig] of servers) {
        console.log(chalk.gray(`  📦 ${serverId}:`));
        console.log(chalk.gray(`     • Image: ${serverConfig.image}`));
        if (serverConfig.command) {
          console.log(chalk.gray(`     • Command: ${serverConfig.command.join(' ')}`));
        }
        console.log(chalk.gray(`     • Environment: ${Object.keys(serverConfig.environment).length} variables`));
      }
    }
    console.log();
  }

  private async startGateway(config: GatewayConfig, detached: boolean): Promise<void> {
    console.log(chalk.blue('🚀 Starting gateway...'));

    // Show progress indicators
    const steps = [
      'Checking Docker requirements',
      'Creating Docker network',
      'Pulling required images',
      'Starting gateway container',
      'Waiting for gateway to be ready'
    ];

    for (let i = 0; i < steps.length; i++) {
      console.log(chalk.gray(`  ${i + 1}/${steps.length} ${steps[i]}...`));

      // Add small delay to make progress visible
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    const result = await this.orchestrator.startGateway(config);

    if (!result.success) {
      throw new Error(result.error || 'Unknown error occurred');
    }

    console.log(chalk.green('  ✅ Gateway started successfully'));

    if (detached) {
      console.log(chalk.cyan('  🔗 Running in detached mode'));
    }
  }

  private displayPostStartupInfo(config: GatewayConfig): void {
    console.log(chalk.cyan('\n📡 Gateway Information:'));
    console.log(chalk.gray(`  • Gateway URL: http://${config.gateway.host}:${config.gateway.port}`));
    console.log(chalk.gray(`  • Health Check: http://${config.gateway.host}:${config.gateway.port}/health`));
    console.log(chalk.gray(`  • API Endpoint: http://${config.gateway.host}:${config.gateway.port}/mcp`));

    console.log(chalk.cyan('\n🔧 Useful Commands:'));
    console.log(chalk.gray('  • Check status: docker-mcp-gateway status'));
    console.log(chalk.gray('  • View logs: docker-mcp-gateway logs'));
    console.log(chalk.gray('  • Stop gateway: docker-mcp-gateway stop'));

    const serverCount = Object.keys(config.servers).length;
    if (serverCount > 0) {
      console.log(chalk.cyan(`\n📦 ${serverCount} MCP Server(s) Available:`));
      for (const serverId of Object.keys(config.servers)) {
        console.log(chalk.gray(`  • ${serverId}`));
      }
    }

    console.log(chalk.yellow('\n💡 Note: Update your MCP clients to connect to the gateway endpoint'));
  }
}
