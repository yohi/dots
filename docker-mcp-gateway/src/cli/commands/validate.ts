/**
 * Validate Command
 * Validates Docker MCP Gateway configuration
 */

import chalk from 'chalk';
import fs from 'fs-extra';
import yaml from 'yaml';
import {
  CLICommand,
  CLIConfig,
  ConfigurationManager,
  GatewayConfig,
  ValidationResult
} from '../../types/interfaces.js';

interface ValidateOptions {
  configFile?: string;
  fix?: boolean;
}

export class ValidateCommand implements CLICommand {
  name = 'validate';
  description = 'Docker MCP Gateway 設定を検証';

  constructor(
    private configManager: ConfigurationManager
  ) { }

  async execute(options: ValidateOptions, cliConfig: CLIConfig): Promise<void> {
    console.log(chalk.blue('🔍 Validating Docker MCP Gateway Configuration'));
    console.log(chalk.gray('==============================================\n'));

    try {
      // Load configuration
      const config = await this.loadConfiguration(options.configFile);

      // Perform validation
      const validation = await this.validateConfiguration(config);

      // Display results
      this.displayValidationResults(validation);

      // Attempt fixes if requested and possible
      if (options.fix && !validation.isValid) {
        await this.attemptAutoFix(config, validation, options.configFile);
      }

      // Summary
      this.displaySummary(validation);

      if (!validation.isValid) {
        process.exit(1);
      }

    } catch (error) {
      throw new Error(`Validation failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async loadConfiguration(configFile?: string): Promise<GatewayConfig> {
    console.log(chalk.blue('📖 Loading configuration...'));

    try {
      let configPath: string;

      if (configFile) {
        configPath = configFile;
        console.log(chalk.gray(`Using specified config: ${configPath}`));
      } else {
        configPath = this.configManager.getConfigPath();
        console.log(chalk.gray(`Using default config: ${configPath}`));
      }

      if (!await fs.pathExists(configPath)) {
        throw new Error(
          `Configuration file not found: ${configPath}\n` +
          'Run "docker-mcp-gateway migrate" to create initial configuration'
        );
      }

      const configContent = await fs.readFile(configPath, 'utf-8');

      try {
        const config = yaml.parse(configContent) as GatewayConfig;
        console.log(chalk.green('✅ Configuration loaded successfully\n'));
        return config;
      } catch (parseError) {
        throw new Error(`Configuration file is not valid YAML: ${parseError instanceof Error ? parseError.message : String(parseError)}`);
      }

    } catch (error) {
      throw new Error(`Failed to load configuration: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async validateConfiguration(config: GatewayConfig): Promise<ValidationResult> {
    console.log(chalk.blue('🔍 Performing validation checks...'));

    const validation = await this.configManager.validateConfig(config);

    console.log(chalk.gray(`  • Schema validation: ${validation.isValid ? 'PASS' : 'FAIL'}`));
    console.log(chalk.gray(`  • Errors found: ${validation.errors.length}`));
    console.log(chalk.gray(`  • Warnings found: ${validation.warnings.length}\n`));

    return validation;
  }

  private displayValidationResults(validation: ValidationResult): void {
    if (validation.isValid) {
      console.log(chalk.green('✅ Configuration is valid!'));
    } else {
      console.log(chalk.red('❌ Configuration validation failed'));
    }
    console.log();

    // Display errors
    if (validation.errors.length > 0) {
      console.log(chalk.red('🚨 Errors:'));
      for (const error of validation.errors) {
        console.log(chalk.red(`  ❌ ${error.field}: ${error.message}`));
        console.log(chalk.gray(`     Code: ${error.code}`));
      }
      console.log();
    }

    // Display warnings
    if (validation.warnings.length > 0) {
      console.log(chalk.yellow('⚠️  Warnings:'));
      for (const warning of validation.warnings) {
        console.log(chalk.yellow(`  ⚠️  ${warning}`));
      }
      console.log();
    }

    // Display recommendations
    if (validation.errors.length > 0 || validation.warnings.length > 0) {
      this.displayRecommendations(validation);
    }
  }

  private displayRecommendations(validation: ValidationResult): void {
    console.log(chalk.cyan('💡 Recommendations:'));

    // Error-specific recommendations
    for (const error of validation.errors) {
      switch (error.code) {
        case 'REQUIRED_FIELD':
          console.log(chalk.gray(`  • Add the missing field: ${error.field}`));
          break;
        case 'INVALID_TYPE':
          console.log(chalk.gray(`  • Fix the data type for: ${error.field}`));
          break;
        case 'INVALID_FORMAT':
          console.log(chalk.gray(`  • Check the format for: ${error.field}`));
          break;
        case 'ID_MISMATCH':
          console.log(chalk.gray(`  • Ensure server IDs match their configuration keys`));
          break;
        default:
          console.log(chalk.gray(`  • Review and fix: ${error.field}`));
      }
    }

    // General recommendations
    if (validation.warnings.length > 0) {
      console.log(chalk.gray('  • Review warnings and consider addressing them'));
    }

    console.log(chalk.gray('  • Run with --fix to attempt automatic fixes'));
    console.log(chalk.gray('  • Refer to documentation for configuration examples'));
    console.log();
  }

  private async attemptAutoFix(config: GatewayConfig, validation: ValidationResult, configFile?: string): Promise<void> {
    console.log(chalk.blue('🔧 Attempting automatic fixes...'));

    let fixedConfig = { ...config };
    let fixApplied = false;

    // Attempt to fix common issues
    for (const error of validation.errors) {
      switch (error.code) {
        case 'ID_MISMATCH':
          // Fix server ID mismatches
          for (const [serverId, serverConfig] of Object.entries(fixedConfig.servers)) {
            if (serverConfig.id !== serverId) {
              console.log(chalk.gray(`  🔧 Fixing server ID mismatch: ${serverId}`));
              fixedConfig.servers[serverId].id = serverId;
              fixApplied = true;
            }
          }
          break;

        case 'INVALID_FORMAT':
          if (error.field === 'network.name') {
            // Fix network name format
            const invalidChars = /[^a-zA-Z0-9_.-]/g;
            if (fixedConfig.network.name.match(invalidChars)) {
              console.log(chalk.gray(`  🔧 Fixing network name format`));
              fixedConfig.network.name = fixedConfig.network.name.replace(invalidChars, '-');
              fixApplied = true;
            }
          }
          break;
      }
    }

    if (fixApplied) {
      // Re-validate after fixes
      const newValidation = await this.configManager.validateConfig(fixedConfig);

      if (newValidation.isValid || newValidation.errors.length < validation.errors.length) {
        // Save fixed configuration
        const configPath = configFile || this.configManager.getConfigPath();
        const yamlContent = yaml.stringify(fixedConfig, { indent: 2 });
        await fs.writeFile(configPath, yamlContent, 'utf-8');

        console.log(chalk.green('✅ Automatic fixes applied and saved'));
        console.log(chalk.gray(`  • Fixed ${validation.errors.length - newValidation.errors.length} error(s)`));

        if (newValidation.errors.length > 0) {
          console.log(chalk.yellow(`  • ${newValidation.errors.length} error(s) still require manual attention`));
        }
      } else {
        console.log(chalk.yellow('⚠️  Automatic fixes did not improve validation'));
      }
    } else {
      console.log(chalk.yellow('⚠️  No automatic fixes available for current errors'));
    }
    console.log();
  }

  private displaySummary(validation: ValidationResult): void {
    console.log(chalk.blue('📊 Validation Summary'));
    console.log(chalk.gray('==================='));

    if (validation.isValid) {
      console.log(chalk.green('✅ Configuration is VALID'));
      console.log(chalk.gray('   Ready for deployment'));
    } else {
      console.log(chalk.red('❌ Configuration is INVALID'));
      console.log(chalk.gray(`   ${validation.errors.length} error(s) must be fixed`));
    }

    if (validation.warnings.length > 0) {
      console.log(chalk.yellow(`⚠️  ${validation.warnings.length} warning(s) found`));
      console.log(chalk.gray('   Consider addressing warnings for optimal performance'));
    }

    console.log();
    console.log(chalk.cyan('Next steps:'));
    if (validation.isValid) {
      console.log(chalk.gray('  • Start gateway: docker-mcp-gateway start'));
      console.log(chalk.gray('  • Check status: docker-mcp-gateway status'));
    } else {
      console.log(chalk.gray('  • Fix configuration errors'));
      console.log(chalk.gray('  • Re-run validation: docker-mcp-gateway validate'));
      console.log(chalk.gray('  • Use --fix for automatic fixes: docker-mcp-gateway validate --fix'));
    }
  }
}
