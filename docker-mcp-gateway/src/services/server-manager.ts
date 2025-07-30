/**
 * Server Manager Service
 * Docker MCP Gateway 内の個別MCPサーバーを管理します
 */

import Docker from 'dockerode';
import fs from 'fs-extra';
import path from 'path';
import yaml from 'yaml';
import {
  ServerManager,
  ServerConfig,
  ServerStatus,
  OperationResult,
  GatewayConfig,
  ConfigurationManager
} from '../types/interfaces.js';

export class ServerManagerImpl implements ServerManager {
  private readonly docker: Docker;
  private readonly configManager: ConfigurationManager;

  constructor(configManager: ConfigurationManager) {
    this.docker = new Docker();
    this.configManager = configManager;
  }

  /**
   * ゲートウェイ設定に新しいMCPサーバーを追加
   */
  async addServer(serverConfig: ServerConfig): Promise<OperationResult> {
    try {
      // Validate server configuration
      const validation = this.validateServerConfig(serverConfig);
      if (!validation.isValid) {
        return {
          success: false,
          error: `Invalid server configuration: ${validation.errors.join(', ')}`
        };
      }

      // Load current gateway configuration
      const gatewayConfig = await this.loadGatewayConfig();

      // Check if server already exists
      if (gatewayConfig.servers[serverConfig.id]) {
        return {
          success: false,
          error: `Server with ID '${serverConfig.id}' already exists`
        };
      }

      // Add server to configuration
      gatewayConfig.servers[serverConfig.id] = serverConfig;

      // Save updated configuration
      await this.saveGatewayConfig(gatewayConfig);

      // If gateway is running, trigger configuration reload
      await this.reloadGatewayConfig(gatewayConfig);

      return {
        success: true,
        data: {
          serverId: serverConfig.id,
          message: 'Server added successfully'
        }
      };

    } catch (error) {
      return {
        success: false,
        error: `Failed to add server: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  /**
   * Remove an MCP server from the gateway configuration
   */
  async removeServer(serverId: string): Promise<OperationResult> {
    try {
      // Load current gateway configuration
      const gatewayConfig = await this.loadGatewayConfig();

      // Check if server exists
      if (!gatewayConfig.servers[serverId]) {
        return {
          success: false,
          error: `Server with ID '${serverId}' not found`
        };
      }

      // Store server info for response
      const removedServer = gatewayConfig.servers[serverId];

      // Remove server from configuration
      delete gatewayConfig.servers[serverId];

      // Save updated configuration
      await this.saveGatewayConfig(gatewayConfig);

      // If gateway is running, trigger configuration reload
      await this.reloadGatewayConfig(gatewayConfig);

      return {
        success: true,
        data: {
          serverId,
          serverName: removedServer.name,
          message: 'Server removed successfully'
        }
      };

    } catch (error) {
      return {
        success: false,
        error: `Failed to remove server: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  /**
   * Update an existing MCP server configuration
   */
  async updateServer(serverId: string, config: ServerConfig): Promise<OperationResult> {
    try {
      // Ensure the server ID matches
      if (config.id !== serverId) {
        return {
          success: false,
          error: 'Server ID in configuration must match the provided server ID'
        };
      }

      // Validate server configuration
      const validation = this.validateServerConfig(config);
      if (!validation.isValid) {
        return {
          success: false,
          error: `Invalid server configuration: ${validation.errors.join(', ')}`
        };
      }

      // Load current gateway configuration
      const gatewayConfig = await this.loadGatewayConfig();

      // Check if server exists
      if (!gatewayConfig.servers[serverId]) {
        return {
          success: false,
          error: `Server with ID '${serverId}' not found`
        };
      }

      // Update server configuration
      gatewayConfig.servers[serverId] = config;

      // Save updated configuration
      await this.saveGatewayConfig(gatewayConfig);

      // If gateway is running, trigger configuration reload
      await this.reloadGatewayConfig(gatewayConfig);

      return {
        success: true,
        data: {
          serverId,
          message: 'Server updated successfully'
        }
      };

    } catch (error) {
      return {
        success: false,
        error: `Failed to update server: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  /**
   * Get the status of a specific MCP server
   */
  async getServerStatus(serverId: string): Promise<ServerStatus> {
    try {
      // Load gateway configuration to verify server exists
      const gatewayConfig = await this.loadGatewayConfig();

      if (!gatewayConfig.servers[serverId]) {
        return {
          id: serverId,
          status: 'error',
          uptime: 0,
          errorMessage: 'Server not found in configuration'
        };
      }

      // Try to get server status from gateway container
      const gatewayContainer = await this.findGatewayContainer();
      if (!gatewayContainer) {
        return {
          id: serverId,
          status: 'stopped',
          uptime: 0,
          errorMessage: 'Gateway container not found'
        };
      }

      const containerInfo = await gatewayContainer.inspect();
      if (!containerInfo.State.Running) {
        return {
          id: serverId,
          status: 'stopped',
          uptime: 0,
          errorMessage: 'Gateway container is not running'
        };
      }

      // In a real implementation, this would query the gateway API
      // For now, we'll simulate server status based on gateway state
      const startTime = new Date(containerInfo.State.StartedAt);
      const uptime = Date.now() - startTime.getTime();

      return {
        id: serverId,
        status: 'running',
        uptime,
        lastHealthCheck: new Date()
      };

    } catch (error) {
      return {
        id: serverId,
        status: 'error',
        uptime: 0,
        errorMessage: error instanceof Error ? error.message : String(error)
      };
    }
  }

  /**
   * List all configured MCP servers
   */
  async listServers(): Promise<ServerConfig[]> {
    try {
      const gatewayConfig = await this.loadGatewayConfig();
      return Object.values(gatewayConfig.servers);
    } catch (error) {
      console.error('Failed to list servers:', error);
      return [];
    }
  }

  /**
   * Restart a specific MCP server
   */
  async restartServer(serverId: string): Promise<OperationResult> {
    try {
      // Load gateway configuration to verify server exists
      const gatewayConfig = await this.loadGatewayConfig();

      if (!gatewayConfig.servers[serverId]) {
        return {
          success: false,
          error: `Server with ID '${serverId}' not found`
        };
      }

      // Check if gateway is running
      const gatewayContainer = await this.findGatewayContainer();
      if (!gatewayContainer) {
        return {
          success: false,
          error: 'Gateway container not found. Start the gateway first.'
        };
      }

      const containerInfo = await gatewayContainer.inspect();
      if (!containerInfo.State.Running) {
        return {
          success: false,
          error: 'Gateway container is not running. Start the gateway first.'
        };
      }

      // In a real implementation, this would call the gateway API to restart the specific server
      // For now, we'll simulate the restart by triggering a config reload
      await this.reloadGatewayConfig(gatewayConfig);

      return {
        success: true,
        data: {
          serverId,
          message: 'Server restart initiated'
        }
      };

    } catch (error) {
      return {
        success: false,
        error: `Failed to restart server: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  // Private helper methods

  private validateServerConfig(config: ServerConfig): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (!config.id || typeof config.id !== 'string') {
      errors.push('Server ID is required and must be a string');
    }

    if (!config.name || typeof config.name !== 'string') {
      errors.push('Server name is required and must be a string');
    }

    if (!config.image || typeof config.image !== 'string') {
      errors.push('Server image is required and must be a string');
    }

    if (config.command && !Array.isArray(config.command)) {
      errors.push('Server command must be an array of strings');
    }

    if (!config.environment || typeof config.environment !== 'object') {
      errors.push('Server environment must be an object');
    }

    if (typeof config.autoRestart !== 'boolean') {
      errors.push('Server autoRestart must be a boolean');
    }

    // Validate health check if provided
    if (config.healthCheck) {
      if (!Array.isArray(config.healthCheck.command)) {
        errors.push('Health check command must be an array of strings');
      }
      if (typeof config.healthCheck.interval !== 'number' || config.healthCheck.interval <= 0) {
        errors.push('Health check interval must be a positive number');
      }
      if (typeof config.healthCheck.timeout !== 'number' || config.healthCheck.timeout <= 0) {
        errors.push('Health check timeout must be a positive number');
      }
      if (typeof config.healthCheck.retries !== 'number' || config.healthCheck.retries < 0) {
        errors.push('Health check retries must be a non-negative number');
      }
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  private async loadGatewayConfig(): Promise<GatewayConfig> {
    const configPath = this.configManager.getConfigPath();

    if (!await fs.pathExists(configPath)) {
      throw new Error(`Gateway configuration not found at: ${configPath}`);
    }

    const configContent = await fs.readFile(configPath, 'utf-8');
    return yaml.parse(configContent) as GatewayConfig;
  }

  private async saveGatewayConfig(config: GatewayConfig): Promise<void> {
    const configPath = this.configManager.getConfigPath();
    await fs.ensureDir(path.dirname(configPath));

    const yamlContent = yaml.stringify(config, { indent: 2 });
    await fs.writeFile(configPath, yamlContent, 'utf-8');
  }

  private async reloadGatewayConfig(config: GatewayConfig): Promise<void> {
    try {
      const gatewayContainer = await this.findGatewayContainer();
      if (!gatewayContainer) {
        return; // Gateway not running, config will be loaded on next start
      }

      const containerInfo = await gatewayContainer.inspect();
      if (!containerInfo.State.Running) {
        return; // Gateway not running
      }

      // Try to send a reload signal to the gateway container
      try {
        await gatewayContainer.kill({ signal: 'SIGHUP' });
      } catch (signalError) {
        // If signaling doesn't work, the config will be picked up on next restart
        console.warn('Could not send reload signal to gateway, config will be applied on next restart');
      }
    } catch (error) {
      console.warn('Failed to reload gateway configuration:', error);
    }
  }

  private async findGatewayContainer(): Promise<Docker.Container | null> {
    try {
      const containers = await this.docker.listContainers({ all: true });
      const gatewayContainer = containers.find(container =>
        container.Names.some(name => name.includes('mcp-gateway'))
      );

      return gatewayContainer ? this.docker.getContainer(gatewayContainer.Id) : null;
    } catch (error) {
      return null;
    }
  }
}
