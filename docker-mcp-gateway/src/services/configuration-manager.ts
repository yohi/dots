/**
 * Configuration Manager Service
 * MCP設定の解析、検証、移行を処理します
 */

import fs from 'fs-extra';
import path from 'path';
import yaml from 'yaml';
import Joi from 'joi';
import {
  ConfigurationManager,
  MCPConfig,
  MCPServerDefinition,
  GatewayConfig,
  ServerConfig,
  ValidationResult,
  ValidationError,
  OperationResult
} from '../types/interfaces.js';

export class ConfigurationManagerImpl implements ConfigurationManager {
  private readonly configBackupDir: string;
  private readonly mcpConfigPath: string;
  private readonly gatewayConfigPath: string;

  constructor(
    configDir: string = process.cwd(),
    mcpConfigFile: string = 'cursor/mcp.json',
    gatewayConfigFile: string = '.kiro/docker-mcp-gateway/gateway-config.yaml'
  ) {
    this.mcpConfigPath = path.join(configDir, mcpConfigFile);
    this.gatewayConfigPath = path.join(configDir, gatewayConfigFile);
    this.configBackupDir = path.join(configDir, '.kiro/docker-mcp-gateway/config-backups');
  }

  /**
   * Load existing MCP configuration from cursor/mcp.json
   */
  async loadExistingConfig(): Promise<MCPConfig> {
    try {
      if (!await fs.pathExists(this.mcpConfigPath)) {
        throw new Error(`MCP configuration file not found: ${this.mcpConfigPath}`);
      }

      const configContent = await fs.readFile(this.mcpConfigPath, 'utf-8');
      const config = JSON.parse(configContent) as MCPConfig;

      // Validate the loaded configuration
      const validation = this.validateMCPConfig(config);
      if (!validation.isValid) {
        throw new Error(`Invalid MCP configuration: ${validation.errors.map(e => e.message).join(', ')}`);
      }

      return config;
    } catch (error) {
      throw new Error(`Failed to load MCP configuration: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Generate DockerMCPGateway configuration from MCP config
   */
  async generateGatewayConfig(mcpConfig: MCPConfig): Promise<GatewayConfig> {
    const servers: Record<string, ServerConfig> = {};

    // Convert each MCP server definition to gateway server config
    for (const [serverId, serverDef] of Object.entries(mcpConfig.mcpServers)) {
      servers[serverId] = this.convertMCPServerToGatewayServer(serverId, serverDef);
    }

    const gatewayConfig: GatewayConfig = {
      version: '1.0.0',
      gateway: {
        port: 8080,
        host: '0.0.0.0',
        logLevel: 'info'
      },
      servers,
      network: {
        name: 'mcp-gateway-network',
        driver: 'bridge'
      }
    };

    return gatewayConfig;
  }

  /**
   * Validate gateway configuration
   */
  async validateConfig(config: GatewayConfig): Promise<ValidationResult> {
    const errors: ValidationError[] = [];
    const warnings: string[] = [];

    try {
      // Define validation schema
      const schema = Joi.object({
        version: Joi.string().required(),
        gateway: Joi.object({
          port: Joi.number().port().required(),
          host: Joi.string().required(),
          logLevel: Joi.string().valid('debug', 'info', 'warn', 'error').required()
        }).required(),
        servers: Joi.object().pattern(
          Joi.string(),
          Joi.object({
            id: Joi.string().required(),
            name: Joi.string().required(),
            image: Joi.string().required(),
            command: Joi.array().items(Joi.string()).optional(),
            environment: Joi.object().pattern(Joi.string(), Joi.string()).required(),
            volumes: Joi.array().items(Joi.object({
              source: Joi.string().required(),
              target: Joi.string().required(),
              readonly: Joi.boolean().optional()
            })).optional(),
            healthCheck: Joi.object({
              command: Joi.array().items(Joi.string()).required(),
              interval: Joi.number().positive().required(),
              timeout: Joi.number().positive().required(),
              retries: Joi.number().positive().required()
            }).optional(),
            autoRestart: Joi.boolean().required()
          })
        ).required(),
        network: Joi.object({
          name: Joi.string().required(),
          driver: Joi.string().required()
        }).required()
      });

      const { error } = schema.validate(config, { abortEarly: false });

      if (error) {
        for (const detail of error.details) {
          errors.push({
            field: detail.path.join('.'),
            message: detail.message,
            code: detail.type
          });
        }
      }

      // Additional validations
      this.validateServerConfigurations(config, errors, warnings);
      this.validateNetworkConfiguration(config, errors, warnings);

    } catch (error) {
      errors.push({
        field: 'general',
        message: `Validation error: ${error instanceof Error ? error.message : String(error)}`,
        code: 'VALIDATION_ERROR'
      });
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings
    };
  }

  /**
   * Migrate MCP configuration to gateway format
   */
  async migrateConfig(source: MCPConfig): Promise<GatewayConfig> {
    // Create backup of current configuration
    await this.createConfigBackup();

    // Generate new gateway configuration
    const gatewayConfig = await this.generateGatewayConfig(source);

    // Validate the generated configuration
    const validation = await this.validateConfig(gatewayConfig);
    if (!validation.isValid) {
      throw new Error(`Generated configuration is invalid: ${validation.errors.map(e => e.message).join(', ')}`);
    }

    return gatewayConfig;
  }

  /**
   * Rollback to previous configuration
   */
  async rollbackConfig(): Promise<void> {
    try {
      // Find the most recent backup
      const backupFiles = await fs.readdir(this.configBackupDir);
      const gatewayBackups = backupFiles
        .filter(file => file.startsWith('gateway-config-') && file.endsWith('.yaml'))
        .sort()
        .reverse();

      if (gatewayBackups.length === 0) {
        throw new Error('No configuration backups found');
      }

      const latestBackup = path.join(this.configBackupDir, gatewayBackups[0]);
      await fs.copy(latestBackup, this.gatewayConfigPath);

    } catch (error) {
      throw new Error(`Failed to rollback configuration: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Save gateway configuration to file
   */
  async saveConfig(config: GatewayConfig): Promise<void> {
    try {
      // Ensure directory exists
      await fs.ensureDir(path.dirname(this.gatewayConfigPath));

      // Save configuration as YAML
      const yamlContent = yaml.stringify(config, { indent: 2 });
      await fs.writeFile(this.gatewayConfigPath, yamlContent, 'utf-8');

    } catch (error) {
      throw new Error(`Failed to save configuration: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Get configuration file path
   */
  getConfigPath(): string {
    return this.gatewayConfigPath;
  }

  // Private helper methods

  private validateMCPConfig(config: MCPConfig): ValidationResult {
    const errors: ValidationError[] = [];

    if (!config.mcpServers || typeof config.mcpServers !== 'object') {
      errors.push({
        field: 'mcpServers',
        message: 'mcpServers must be an object',
        code: 'INVALID_TYPE'
      });
      return { isValid: false, errors, warnings: [] };
    }

    for (const [serverId, serverDef] of Object.entries(config.mcpServers)) {
      if (!serverDef.command) {
        errors.push({
          field: `mcpServers.${serverId}.command`,
          message: 'command is required',
          code: 'REQUIRED_FIELD'
        });
      }
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings: []
    };
  }

  private convertMCPServerToGatewayServer(serverId: string, serverDef: MCPServerDefinition): ServerConfig {
    // Determine the appropriate Docker image based on the command
    let image: string;
    let command: string[] | undefined;

    if (serverDef.command.startsWith('uvx')) {
      // Python-based MCP server
      image = 'python:3.11-slim';
      command = ['uvx', ...serverDef.args || []];
    } else if (serverDef.command.startsWith('npx')) {
      // Node.js-based MCP server
      image = 'node:18-alpine';
      command = ['npx', ...serverDef.args || []];
    } else if (serverDef.command.startsWith('docker')) {
      // Already Docker-based
      image = 'docker:latest';
      command = serverDef.args;
    } else {
      // Generic case
      image = 'alpine:latest';
      command = [serverDef.command, ...serverDef.args || []];
    }

    return {
      id: serverId,
      name: `MCP Server: ${serverId}`,
      image,
      command,
      environment: {
        ...serverDef.env,
        MCP_SERVER_ID: serverId
      },
      autoRestart: true,
      healthCheck: {
        command: ['echo', 'health-check'],
        interval: 30000,
        timeout: 5000,
        retries: 3
      }
    };
  }

  private validateServerConfigurations(config: GatewayConfig, errors: ValidationError[], warnings: string[]): void {
    if (Object.keys(config.servers).length === 0) {
      warnings.push('No servers configured');
    }

    for (const [serverId, serverConfig] of Object.entries(config.servers)) {
      if (serverConfig.id !== serverId) {
        errors.push({
          field: `servers.${serverId}.id`,
          message: 'Server ID must match the key in servers object',
          code: 'ID_MISMATCH'
        });
      }

      if (!serverConfig.image.includes(':')) {
        warnings.push(`Server ${serverId}: No tag specified for Docker image ${serverConfig.image}`);
      }
    }
  }

  private validateNetworkConfiguration(config: GatewayConfig, errors: ValidationError[], warnings: string[]): void {
    if (!config.network.name.match(/^[a-zA-Z0-9][a-zA-Z0-9_.-]*$/)) {
      errors.push({
        field: 'network.name',
        message: 'Invalid network name format',
        code: 'INVALID_FORMAT'
      });
    }
  }

  private async createConfigBackup(): Promise<void> {
    try {
      await fs.ensureDir(this.configBackupDir);

      if (await fs.pathExists(this.gatewayConfigPath)) {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const backupPath = path.join(this.configBackupDir, `gateway-config-${timestamp}.yaml`);
        await fs.copy(this.gatewayConfigPath, backupPath);
      }

      // Clean up old backups (keep only last 10)
      const backupFiles = await fs.readdir(this.configBackupDir);
      const gatewayBackups = backupFiles
        .filter(file => file.startsWith('gateway-config-') && file.endsWith('.yaml'))
        .sort()
        .reverse();

      if (gatewayBackups.length > 10) {
        for (const oldBackup of gatewayBackups.slice(10)) {
          await fs.remove(path.join(this.configBackupDir, oldBackup));
        }
      }

    } catch (error) {
      // Log warning but don't fail the operation
      console.warn(`Failed to create config backup: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}
