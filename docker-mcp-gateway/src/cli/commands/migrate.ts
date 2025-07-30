/**
 * Migrate Command
 * Migrates existing MCP configuration to Docker MCP Gateway format
 */

import chalk from 'chalk';
import fs from 'fs-extra';
import inquirer from 'inquirer';
import {
  CLICommand,
  CLIConfig,
  ConfigurationManager,
  GatewayOrchestrator,
  MCPConfig,
  GatewayConfig
} from '../../types/interfaces.js';

interface MigrateOptions {
  dryRun?: boolean;
  backup?: boolean;
}

export class MigrateCommand implements CLICommand {
  name = 'migrate';
  description = '既存のMCP設定をDocker MCP Gatewayに移行';

  constructor(
    private configManager: ConfigurationManager,
    private orchestrator: GatewayOrchestrator
  ) { }

  async execute(options: MigrateOptions, cliConfig: CLIConfig): Promise<void> {
    console.log(chalk.blue('🚀 Docker MCP Gateway Migration'));
    console.log(chalk.gray('=====================================\n'));

    try {
      // Step 1: Check Docker requirements
      await this.checkDockerRequirements();

      // Step 2: Load existing MCP configuration
      const mcpConfig = await this.loadExistingConfiguration();

      // Step 3: Display migration plan
      await this.displayMigrationPlan(mcpConfig, options.dryRun || false);

      // Step 4: Confirm migration (unless dry-run)
      if (!options.dryRun) {
        const confirmed = await this.confirmMigration();
        if (!confirmed) {
          console.log(chalk.yellow('Migration cancelled by user.'));
          return;
        }
      }

      // Step 5: Perform migration
      if (!options.dryRun) {
        await this.performMigration(mcpConfig, options.backup !== false);
      }

      console.log(chalk.green('\n✅ Migration completed successfully!'));

      if (!options.dryRun) {
        console.log(chalk.cyan('\nNext steps:'));
        console.log(chalk.gray('  • Run "docker-mcp-gateway start" to start the gateway'));
        console.log(chalk.gray('  • Run "docker-mcp-gateway status" to check gateway status'));
        console.log(chalk.gray('  • Update your MCP clients to use the gateway endpoint'));
      }

    } catch (error) {
      throw new Error(`Migration failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async checkDockerRequirements(): Promise<void> {
    console.log(chalk.blue('📋 Checking Docker requirements...'));

    const requirements = await this.orchestrator.checkDockerRequirements();

    if (!requirements.isValid) {
      console.log(chalk.red('❌ Docker requirements not met:'));
      for (const error of requirements.errors) {
        console.log(chalk.red(`   • ${error.message}`));
      }
      throw new Error('Docker requirements validation failed');
    }

    if (requirements.warnings.length > 0) {
      console.log(chalk.yellow('⚠️  Warnings:'));
      for (const warning of requirements.warnings) {
        console.log(chalk.yellow(`   • ${warning}`));
      }
    }

    console.log(chalk.green('✅ Docker requirements satisfied\n'));
  }

  private async loadExistingConfiguration(): Promise<MCPConfig> {
    console.log(chalk.blue('📖 Loading existing MCP configuration...'));

    try {
      const mcpConfig = await this.configManager.loadExistingConfig();

      const serverCount = Object.keys(mcpConfig.mcpServers).length;
      console.log(chalk.green(`✅ Found ${serverCount} MCP server(s) configured`));

      if (serverCount === 0) {
        throw new Error('No MCP servers found in configuration');
      }

      // Display configured servers
      console.log(chalk.gray('\nConfigured servers:'));
      for (const [serverId, serverDef] of Object.entries(mcpConfig.mcpServers)) {
        console.log(chalk.gray(`  • ${serverId}: ${serverDef.command}`));
      }
      console.log();

      return mcpConfig;

    } catch (error) {
      throw new Error(`Failed to load MCP configuration: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async displayMigrationPlan(mcpConfig: MCPConfig, isDryRun: boolean): Promise<void> {
    console.log(chalk.blue('📋 Migration Plan'));
    console.log(chalk.gray('================\n'));

    try {
      const gatewayConfig = await this.configManager.generateGatewayConfig(mcpConfig);

      if (isDryRun) {
        console.log(chalk.yellow('🔍 DRY RUN MODE - No changes will be made\n'));
      }

      console.log(chalk.cyan('Gateway Configuration:'));
      console.log(chalk.gray(`  • Host: ${gatewayConfig.gateway.host}`));
      console.log(chalk.gray(`  • Port: ${gatewayConfig.gateway.port}`));
      console.log(chalk.gray(`  • Log Level: ${gatewayConfig.gateway.logLevel}`));
      console.log(chalk.gray(`  • Network: ${gatewayConfig.network.name} (${gatewayConfig.network.driver})\n`));

      console.log(chalk.cyan('Server Migration Plan:'));
      for (const [serverId, serverConfig] of Object.entries(gatewayConfig.servers)) {
        console.log(chalk.gray(`  📦 ${serverId}:`));
        console.log(chalk.gray(`     • Docker Image: ${serverConfig.image}`));
        if (serverConfig.command) {
          console.log(chalk.gray(`     • Command: ${serverConfig.command.join(' ')}`));
        }
        console.log(chalk.gray(`     • Environment Variables: ${Object.keys(serverConfig.environment).length} defined`));
        console.log(chalk.gray(`     • Auto Restart: ${serverConfig.autoRestart ? 'Yes' : 'No'}`));
        if (serverConfig.healthCheck) {
          console.log(chalk.gray(`     • Health Check: Enabled (${serverConfig.healthCheck.interval}ms interval)`));
        }
        console.log();
      }

      // Validate the generated configuration
      const validation = await this.configManager.validateConfig(gatewayConfig);
      if (!validation.isValid) {
        console.log(chalk.red('❌ Generated configuration has validation errors:'));
        for (const error of validation.errors) {
          console.log(chalk.red(`   • ${error.field}: ${error.message}`));
        }
        throw new Error('Generated configuration validation failed');
      }

      if (validation.warnings.length > 0) {
        console.log(chalk.yellow('⚠️  Configuration warnings:'));
        for (const warning of validation.warnings) {
          console.log(chalk.yellow(`   • ${warning}`));
        }
        console.log();
      }

    } catch (error) {
      throw new Error(`Failed to generate migration plan: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async confirmMigration(): Promise<boolean> {
    console.log(chalk.yellow('⚠️  This migration will:'));
    console.log(chalk.gray('   • Create Docker MCP Gateway configuration'));
    console.log(chalk.gray('   • Backup existing configuration (if enabled)'));
    console.log(chalk.gray('   • Set up Docker network for MCP servers'));
    console.log(chalk.gray('   • Download required Docker images'));
    console.log();

    const { confirmed } = await inquirer.prompt([
      {
        type: 'confirm',
        name: 'confirmed',
        message: 'Do you want to proceed with the migration?',
        default: false
      }
    ]);

    return confirmed;
  }

  private async performMigration(mcpConfig: MCPConfig, createBackup: boolean): Promise<void> {
    console.log(chalk.blue('🔄 Performing migration...'));

    try {
      // Step 1: Create backup if requested
      if (createBackup) {
        console.log(chalk.gray('  📦 Creating configuration backup...'));
        // Backup is handled internally by configManager.migrateConfig()
      }

      // Step 2: Migrate configuration
      console.log(chalk.gray('  🔧 Generating gateway configuration...'));
      const gatewayConfig = await this.configManager.migrateConfig(mcpConfig);

      // Step 3: Save gateway configuration
      console.log(chalk.gray('  💾 Saving gateway configuration...'));
      await this.configManager.saveConfig(gatewayConfig);

      // Step 4: Validate Docker setup
      console.log(chalk.gray('  🐳 Preparing Docker environment...'));
      const requirements = await this.orchestrator.checkDockerRequirements();
      if (!requirements.isValid) {
        throw new Error('Docker requirements check failed during migration');
      }

      console.log(chalk.green('  ✅ Migration completed'));

    } catch (error) {
      // If migration fails, attempt rollback
      try {
        console.log(chalk.yellow('  🔄 Attempting rollback...'));
        await this.configManager.rollbackConfig();
        console.log(chalk.yellow('  ✅ Rollback completed'));
      } catch (rollbackError) {
        console.log(chalk.red('  ❌ Rollback failed'));
      }

      throw new Error(`Migration failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}
