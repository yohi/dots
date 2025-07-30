/**
 * Docker MCP Gateway - メインエントリーポイント
 *
 * このモジュールは、Docker MCP Gateway管理システムのメインクラスと
 * インターフェースをエクスポートし、MCPサーバーオーケストレーション用の
 * 統合APIを提供します。
 */

// コアサービス
export { ConfigurationManagerImpl } from './services/configuration-manager.js';
export { GatewayOrchestratorImpl } from './services/gateway-orchestrator.js';
export { ServerManagerImpl } from './services/server-manager.js';
export { MonitoringServiceImpl } from './services/monitoring-service.js';

// 型とインターフェース
export * from './types/interfaces.js';

// CLIコマンド（プログラム使用向け）
export { MigrateCommand } from './cli/commands/migrate.js';
export { StartCommand } from './cli/commands/start.js';
export { StopCommand } from './cli/commands/stop.js';
export { StatusCommand } from './cli/commands/status.js';
export { RestartCommand } from './cli/commands/restart.js';
export { ValidateCommand } from './cli/commands/validate.js';
export { LogsCommand } from './cli/commands/logs.js';
export { HealthCommand } from './cli/commands/health.js';

/**
 * 新しいDocker MCP Gateway Managerインスタンスを作成
 *
 * @param configDir - 設定ファイルのベースディレクトリ
 * @returns Object with all management services and convenience methods
 */
export function createGatewayManager(configDir?: string) {
  const configManager = new ConfigurationManagerImpl(configDir);
  const orchestrator = new GatewayOrchestratorImpl();
  const serverManager = new ServerManagerImpl(configManager);
  const monitoringService = new MonitoringServiceImpl(configManager);

  return {
    configManager,
    orchestrator,
    serverManager,
    monitoringService,

    // Convenience methods
    async migrate() {
      const mcpConfig = await configManager.loadExistingConfig();
      const gatewayConfig = await configManager.migrateConfig(mcpConfig);
      await configManager.saveConfig(gatewayConfig);
      return gatewayConfig;
    },

    async start(config?: any) {
      if (!config) {
        // Load from default location
        const configPath = configManager.getConfigPath();
        const fs = await import('fs-extra');
        const yaml = await import('yaml');
        const configContent = await fs.readFile(configPath, 'utf-8');
        config = yaml.parse(configContent);
      }

      // Start monitoring when gateway starts
      const result = await orchestrator.startGateway(config);
      if (result.success) {
        await monitoringService.startMonitoring();
      }
      return result;
    },

    async stop() {
      // Stop monitoring when gateway stops
      await monitoringService.stopMonitoring();
      return await orchestrator.stopGateway();
    },

    async status() {
      return await orchestrator.getGatewayStatus();
    },

    async restart() {
      // Stop monitoring during restart
      await monitoringService.stopMonitoring();
      const result = await orchestrator.restartGateway();
      if (result.success) {
        await monitoringService.startMonitoring();
      }
      return result;
    },

    // Server management convenience methods
    async addServer(serverConfig: any) {
      return await serverManager.addServer(serverConfig);
    },

    async removeServer(serverId: string) {
      return await serverManager.removeServer(serverId);
    },

    async listServers() {
      return await serverManager.listServers();
    },

    // Monitoring convenience methods
    async getMetrics() {
      return await monitoringService.getMetrics();
    },

    async getLogs(filter?: any) {
      return await monitoringService.getLogs(filter);
    },

    async performHealthCheck() {
      return await monitoringService.performHealthCheck();
    },

    async generateDiagnosticReport() {
      return await monitoringService.generateDiagnosticReport();
    }
  };
}

/**
 * Default export for common usage
 */
export default {
  ConfigurationManagerImpl,
  GatewayOrchestratorImpl,
  ServerManagerImpl,
  MonitoringServiceImpl,
  createGatewayManager
};
