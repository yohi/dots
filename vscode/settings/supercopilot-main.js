/**
 * SuperCopilot Framework - メインシステム
 *
 * VSCode/GitHub Copilot向けのメインシステム
 * ペルソナ自動選択機能とコマンド処理機能を統合
 */

// 必要なモジュールをインポート
const superCopilot = require('./supercopilot');
const { PersonaSelector } = require('./persona-selector');
const { CommandsHandler } = require('./commands-handler');

/**
 * SuperCopilot メインクラス
 * VSCode Copilot拡張用の中心的な機能を提供
 */
class SuperCopilotMain {
  constructor(config = superCopilot) {
    this.config = config;
    this.personaSelector = new PersonaSelector(config);
    this.commandsHandler = new CommandsHandler(config);
    this.initialized = false;
    this.currentContext = {
      filePath: '',
      fileType: '',
      userQuery: '',
      lastPersona: null,
      lastCommand: null
    };

    // デバッグモードの設定
    this.isDevelopment = process.env.NODE_ENV === 'development' ||
      process.env.SUPERCOPILOT_DEBUG === 'true';
  }

  /**
   * ログ出力のためのヘルパーメソッド
   */
  log(level, message, ...args) {
    if (level === 'error') {
      // エラーは常に出力
      console.error(`[SuperCopilot] ${message}`, ...args);
    } else if (this.isDevelopment && level === 'info') {
      // 情報ログは開発モードでのみ出力
      console.log(`[SuperCopilot] ${message}`, ...args);
    }
  }

  /**
   * システムの初期化
   * @returns {boolean} 初期化成功フラグ
   */
  initialize() {
    try {
      // 初期化処理
      this.log('info', 'Initializing...');

      // 設定の確認
      if (!this.config || !this.config.personas || !this.config.commands) {
        this.log('error', 'Configuration is invalid');
        return false;
      }

      this.initialized = true;
      this.log('info', 'Initialized successfully');
      return true;
    } catch (error) {
      this.log('error', `Initialization failed: ${error.message}`);
      return false;
    }
  }

  /**
   * コンテキスト情報を更新
   * @param {Object} contextInfo - コンテキスト情報
   */
  updateContext(contextInfo) {
    if (!contextInfo) return;

    // 必要なプロパティのみ更新
    if (contextInfo.filePath !== undefined) {
      this.currentContext.filePath = contextInfo.filePath;

      // ファイルタイプの抽出
      if (contextInfo.filePath) {
        const fileExtMatch = contextInfo.filePath.match(/\.([^.]+)$/);
        this.currentContext.fileType = fileExtMatch ? fileExtMatch[1] : '';
      }
    }

    if (contextInfo.userQuery !== undefined) {
      this.currentContext.userQuery = contextInfo.userQuery;
    }
  }

  /**
   * ユーザー入力を処理し適切なプロンプトを生成
   * @param {string} userText - ユーザーの入力テキスト
   * @param {string} filePath - 現在のファイルパス
   * @returns {string} 生成されたプロンプト
   */
  processUserInput(userText, filePath = '') {
    if (!this.initialized) {
      this.initialize();
    }

    // コンテキスト更新
    this.updateContext({
      userQuery: userText,
      filePath: filePath
    });

    // コマンドの検出と処理
    const command = this.commandsHandler.detectCommand(userText);
    if (command) {
      this.currentContext.lastCommand = command;
      return this.commandsHandler.generateCommandPrompt(command.name, userText);
    }

    // ペルソナの自動選択
    const personaInfo = this.personaSelector.selectOptimalPersona(filePath, userText);
    this.currentContext.lastPersona = personaInfo.persona;

    return this.personaSelector.generatePersonaPrompt(personaInfo);
  }

  /**
   * VSCode拡張に対するメインエントリポイント
   * @param {Object} params - パラメータ
   * @returns {Object} 処理結果
   */
  handleRequest(params) {
    try {
      const { action, userText, filePath, options } = params || {};

      switch (action) {
        case 'processInput':
          return {
            success: true,
            prompt: this.processUserInput(userText, filePath),
            context: { ...this.currentContext }
          };

        case 'getPersonas':
          return {
            success: true,
            personas: Object.entries(this.config.personas).map(([key, info]) => ({
              key,
              ...info
            }))
          };

        case 'getCommands':
          return {
            success: true,
            commands: this.commandsHandler.getCommandsList()
          };

        case 'generateHelp':
          return {
            success: true,
            helpText: this.commandsHandler.generateHelpText()
          };

        case 'reset':
          this.currentContext = {
            filePath: '',
            fileType: '',
            userQuery: '',
            lastPersona: null,
            lastCommand: null
          };
          return { success: true, message: 'Context reset' };

        default:
          return {
            success: false,
            error: `Unknown action: ${action}`
          };
      }
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * VSCode Copilotにプリプロセッサーとして統合するための関数
   * @param {string} userText - ユーザー入力
   * @param {Object} context - コンテキスト情報
   * @returns {string} 処理後のプロンプト
   */
  static preprocessCopilotPrompt(userText, context = {}) {
    try {
      // シングルトンインスタンスの取得
      if (!SuperCopilotMain._instance) {
        SuperCopilotMain._instance = new SuperCopilotMain();
        SuperCopilotMain._instance.initialize();
      }

      const instance = SuperCopilotMain._instance;
      return instance.processUserInput(userText, context.filePath || '');
    } catch (error) {
      // 環境ベースのロギング：プロダクション環境では詳細なエラー情報を非表示
      const isProduction = process.env.NODE_ENV === 'production' ||
        process.env.VSCODE_ENV === 'production';

      if (isProduction) {
        console.error('[SuperCopilot] An error occurred during preprocessing');
      } else {
        console.error(`[SuperCopilot] Preprocessing error: ${error.message}`);
        console.debug('[SuperCopilot] Error stack:', error.stack);
      }

      return userText; // エラー時は元のテキストをそのまま返す
    }
  }
}

// シングルトンインスタンス
SuperCopilotMain._instance = null;

// エクスポート設定
if (typeof module !== 'undefined') {
  module.exports = {
    SuperCopilotMain
  };
}

// ブラウザ環境で利用する場合
if (typeof window !== 'undefined') {
  window.SuperCopilotMain = SuperCopilotMain;

  // Copilot統合のためのグローバル関数
  window.preprocessCopilotPrompt = SuperCopilotMain.preprocessCopilotPrompt;
}
