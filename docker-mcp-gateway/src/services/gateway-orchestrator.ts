/**
 * Gateway Orchestrator Service
 * DockerMCPGatewayコンテナのライフサイクルとオーケストレーションを管理します
 */

import Docker from 'dockerode';
import fs from 'fs-extra';
import path from 'path';
import yaml from 'yaml';
import {
  GatewayOrchestrator,
  GatewayConfig,
  GatewayStatus,
  OperationResult,
  ValidationResult,
  ValidationError
} from '../types/interfaces.js';

export class GatewayOrchestratorImpl implements GatewayOrchestrator {
  private readonly docker: Docker;
  private readonly containerName: string;
  private readonly networkName: string;
  private readonly gatewayImage: string;
  private gatewayContainer?: Docker.Container;

  constructor(
    containerName: string = 'mcp-gateway',
    gatewayImage: string = 'docker/mcp-gateway:latest'
  ) {
    this.docker = new Docker();
    this.containerName = containerName;
    this.gatewayImage = gatewayImage;
    this.networkName = 'mcp-gateway-network';
  }

  /**
   * Start the DockerMCPGateway container
   */
  async startGateway(config: GatewayConfig): Promise<OperationResult> {
    try {
      // Validate Docker requirements first
      const requirements = await this.checkDockerRequirements();
      if (!requirements.isValid) {
        return {
          success: false,
          error: `Docker requirements not met: ${requirements.errors.map(e => e.message).join(', ')}`
        };
      }

      // Check if gateway is already running
      const existingContainer = await this.findGatewayContainer();
      if (existingContainer) {
        const containerInfo = await existingContainer.inspect();
        if (containerInfo.State.Running) {
          return {
            success: false,
            error: 'Gateway is already running'
          };
        }
        // Remove stopped container
        await existingContainer.remove();
      }

      // Create or ensure network exists
      await this.ensureNetwork(config.network.name, config.network.driver);

      // Create configuration file for the gateway
      const configPath = await this.createGatewayConfigFile(config);

      // Create and start the gateway container
      const container = await this.createGatewayContainer(config, configPath);
      await container.start();

      this.gatewayContainer = container;

      // Wait for the gateway to be ready
      await this.waitForGatewayReady(config.gateway.port);

      return {
        success: true,
        data: {
          containerId: container.id,
          port: config.gateway.port
        }
      };

    } catch (error) {
      return {
        success: false,
        error: `Failed to start gateway: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  /**
   * Stop the DockerMCPGateway container
   */
  async stopGateway(): Promise<OperationResult> {
    try {
      const container = await this.findGatewayContainer();
      if (!container) {
        return {
          success: false,
          error: 'Gateway container not found'
        };
      }

      const containerInfo = await container.inspect();
      if (!containerInfo.State.Running) {
        return {
          success: false,
          error: 'Gateway is not running'
        };
      }

      // Gracefully stop the container
      await container.stop({ t: 30 }); // 30 second timeout
      await container.remove();

      this.gatewayContainer = undefined;

      return {
        success: true
      };

    } catch (error) {
      return {
        success: false,
        error: `Failed to stop gateway: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  /**
   * Restart the DockerMCPGateway container
   */
  async restartGateway(): Promise<OperationResult> {
    try {
      // Get current configuration
      const container = await this.findGatewayContainer();
      if (!container) {
        return {
          success: false,
          error: 'Gateway container not found'
        };
      }

      const containerInfo = await container.inspect();
      const configPath = containerInfo.Mounts?.find(mount =>
        mount.Destination === '/app/config.yaml'
      )?.Source;

      if (!configPath) {
        return {
          success: false,
          error: 'Could not find gateway configuration'
        };
      }

      // Load configuration
      const configContent = await fs.readFile(configPath, 'utf-8');
      const config = yaml.parse(configContent) as GatewayConfig;

      // Stop and start
      const stopResult = await this.stopGateway();
      if (!stopResult.success) {
        return stopResult;
      }

      return await this.startGateway(config);

    } catch (error) {
      return {
        success: false,
        error: `Failed to restart gateway: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  /**
   * Get current gateway status
   */
  async getGatewayStatus(): Promise<GatewayStatus> {
    try {
      const container = await this.findGatewayContainer();
      if (!container) {
        return {
          status: 'stopped',
          uptime: 0,
          version: '1.0.0',
          serversCount: 0
        };
      }

      const containerInfo = await container.inspect();
      const startTime = new Date(containerInfo.State.StartedAt);
      const uptime = Date.now() - startTime.getTime();

      // Count configured servers (this would typically come from the gateway API)
      const configPath = containerInfo.Mounts?.find(mount =>
        mount.Destination === '/app/config.yaml'
      )?.Source;

      let serversCount = 0;
      if (configPath && await fs.pathExists(configPath)) {
        const configContent = await fs.readFile(configPath, 'utf-8');
        const config = yaml.parse(configContent) as GatewayConfig;
        serversCount = Object.keys(config.servers).length;
      }

      return {
        status: containerInfo.State.Running ? 'running' : 'stopped',
        uptime,
        version: '1.0.0',
        serversCount,
        lastRestart: startTime
      };

    } catch (error) {
      return {
        status: 'error',
        uptime: 0,
        version: '1.0.0',
        serversCount: 0
      };
    }
  }

  /**
   * Update gateway configuration
   */
  async updateGatewayConfig(config: GatewayConfig): Promise<OperationResult> {
    try {
      const container = await this.findGatewayContainer();
      if (!container) {
        return {
          success: false,
          error: 'Gateway container not found'
        };
      }

      // Update configuration file
      const containerInfo = await container.inspect();
      const configPath = containerInfo.Mounts?.find(mount =>
        mount.Destination === '/app/config.yaml'
      )?.Source;

      if (!configPath) {
        return {
          success: false,
          error: 'Could not find gateway configuration path'
        };
      }

      const yamlContent = yaml.stringify(config, { indent: 2 });
      await fs.writeFile(configPath, yamlContent, 'utf-8');

      // Send reload signal to container (if supported)
      try {
        await container.kill({ signal: 'SIGHUP' });
      } catch (signalError) {
        // If signal doesn't work, restart the container
        return await this.restartGateway();
      }

      return {
        success: true
      };

    } catch (error) {
      return {
        success: false,
        error: `Failed to update gateway configuration: ${error instanceof Error ? error.message : String(error)}`
      };
    }
  }

  /**
   * Check Docker requirements
   */
  async checkDockerRequirements(): Promise<ValidationResult> {
    const errors: ValidationError[] = [];
    const warnings: string[] = [];

    try {
      // Check if Docker is running
      await this.docker.ping();

      // Check Docker version
      const version = await this.docker.version();
      const versionNumber = parseFloat(version.Version);
      if (versionNumber < 20.10) {
        warnings.push(`Docker version ${version.Version} is older than recommended 20.10+`);
      }

      // Check if the gateway image is available
      try {
        await this.docker.getImage(this.gatewayImage).inspect();
      } catch (imageError) {
        // Try to pull the image
        try {
          await this.pullGatewayImage();
        } catch (pullError) {
          errors.push({
            field: 'docker.image',
            message: `Gateway image ${this.gatewayImage} not available and could not be pulled`,
            code: 'IMAGE_UNAVAILABLE'
          });
        }
      }

      // Check available resources
      const info = await this.docker.info();
      if (info.MemTotal && info.MemTotal < 1024 * 1024 * 1024) { // Less than 1GB
        warnings.push('Less than 1GB of memory available for Docker');
      }

    } catch (error) {
      errors.push({
        field: 'docker.connection',
        message: 'Could not connect to Docker daemon',
        code: 'DOCKER_UNAVAILABLE'
      });
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings
    };
  }

  // Private helper methods

  private async findGatewayContainer(): Promise<Docker.Container | null> {
    try {
      const containers = await this.docker.listContainers({ all: true });
      const gatewayContainer = containers.find(container =>
        container.Names.some(name => name.includes(this.containerName))
      );

      return gatewayContainer ? this.docker.getContainer(gatewayContainer.Id) : null;
    } catch (error) {
      return null;
    }
  }

  private async ensureNetwork(networkName: string, driver: string): Promise<void> {
    try {
      // Check if network exists
      const networks = await this.docker.listNetworks();
      const existingNetwork = networks.find(network => network.Name === networkName);

      if (!existingNetwork) {
        // Create the network
        await this.docker.createNetwork({
          Name: networkName,
          Driver: driver,
          Labels: {
            'mcp-gateway': 'true'
          }
        });
      }
    } catch (error) {
      throw new Error(`Failed to ensure network ${networkName}: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async createGatewayConfigFile(config: GatewayConfig): Promise<string> {
    const configDir = path.join(process.cwd(), '.kiro/docker-mcp-gateway/runtime');
    await fs.ensureDir(configDir);

    const configPath = path.join(configDir, 'gateway-config.yaml');
    const yamlContent = yaml.stringify(config, { indent: 2 });
    await fs.writeFile(configPath, yamlContent, 'utf-8');

    return configPath;
  }

  private async createGatewayContainer(config: GatewayConfig, configPath: string): Promise<Docker.Container> {
    const createOptions: Docker.ContainerCreateOptions = {
      Image: this.gatewayImage,
      name: this.containerName,
      ExposedPorts: {
        [`${config.gateway.port}/tcp`]: {}
      },
      HostConfig: {
        PortBindings: {
          [`${config.gateway.port}/tcp`]: [{ HostPort: config.gateway.port.toString() }]
        },
        Mounts: [
          {
            Type: 'bind',
            Source: configPath,
            Target: '/app/config.yaml',
            ReadOnly: true
          },
          {
            Type: 'bind',
            Source: '/var/run/docker.sock',
            Target: '/var/run/docker.sock',
            ReadOnly: false
          }
        ],
        NetworkMode: config.network.name,
        RestartPolicy: {
          Name: 'unless-stopped'
        }
      },
      Env: [
        `LOG_LEVEL=${config.gateway.logLevel}`,
        `GATEWAY_PORT=${config.gateway.port}`,
        `GATEWAY_HOST=${config.gateway.host}`
      ],
      Labels: {
        'mcp-gateway': 'true',
        'mcp-gateway.version': config.version
      }
    };

    return await this.docker.createContainer(createOptions);
  }

  private async waitForGatewayReady(port: number, timeoutMs: number = 30000): Promise<void> {
    const startTime = Date.now();

    while (Date.now() - startTime < timeoutMs) {
      try {
        // Try to connect to the gateway health endpoint
        const response = await fetch(`http://localhost:${port}/health`);
        if (response.ok) {
          return;
        }
      } catch (error) {
        // Gateway not ready yet, continue waiting
      }

      await new Promise(resolve => setTimeout(resolve, 1000));
    }

    throw new Error(`Gateway did not become ready within ${timeoutMs}ms`);
  }

  private async pullGatewayImage(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.docker.pull(this.gatewayImage, (err, stream) => {
        if (err) {
          reject(err);
          return;
        }

        this.docker.modem.followProgress(stream, (err, output) => {
          if (err) {
            reject(err);
          } else {
            resolve();
          }
        });
      });
    });
  }
}
