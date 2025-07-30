"""
SuperGemini - フレームワークパッケージ
Gemini CLIを拡張する機能を提供します
"""

__version__ = "1.0.0"
__author__ = "SuperGemini Team"
__license__ = "MIT"

import os
import sys
import json
import logging
from pathlib import Path

# グローバル定数
HOME_DIR = str(Path.home())
GEMINI_HOME = os.path.join(HOME_DIR, ".gemini")
SHARED_DIR = os.path.join(GEMINI_HOME, "shared")
COMMANDS_DIR = os.path.join(GEMINI_HOME, "commands")
GEMINI_MD = os.path.join(GEMINI_HOME, "GEMINI.md")

# 設定ファイルのパス
CONFIG_PATH = os.path.join(SHARED_DIR, "settings.json")

# ロガーの設定
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.join(GEMINI_HOME, "supergemini.log")),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger("SuperGemini")

def get_config():
    """
    SuperGeminiの設定を読み込む
    """
    if os.path.exists(CONFIG_PATH):
        try:
            with open(CONFIG_PATH, 'r') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"設定ファイルの読み込みエラー: {e}")
            return {}
    else:
        # デフォルト設定
        default_config = {
            "version": __version__,
            "personas": ["architect", "developer", "analyst", "tester", "devops", "security", "frontend", "backend", "scribe"],
            "commands": {
                "analyze": {"enabled": True, "description": "コード分析、問題特定、改善提案"},
                "explain": {"enabled": True, "description": "コードの動作説明、アルゴリズム解説"},
                "troubleshoot": {"enabled": True, "description": "バグ解析、エラー原因特定、解決策提示"},
                "implement": {"enabled": True, "description": "機能実装、新規開発"},
                "improve": {"enabled": True, "description": "リファクタリング、最適化"},
                "build": {"enabled": True, "description": "ビルド、コンパイル、パッケージング"},
                "design": {"enabled": True, "description": "アーキテクチャ設計、システム設計"},
                "estimate": {"enabled": True, "description": "作業工数見積もり、スケジュール算出"},
                "task": {"enabled": True, "description": "タスク分解、作業計画"},
                "workflow": {"enabled": True, "description": "ワークフロー設計、プロセス改善"},
                "document": {"enabled": True, "description": "ドキュメント生成、仕様書作成"},
                "test": {"enabled": True, "description": "テスト作成、テスト実行計画"},
                "git": {"enabled": True, "description": "Git操作、ブランチ戦略"},
                "cleanup": {"enabled": True, "description": "コード整理、不要ファイル削除"},
                "load": {"enabled": True, "description": "プロジェクト構造分析、依存関係把握"},
                "index": {"enabled": True, "description": "コードベース索引化、関連性分析"},
                "spawn": {"enabled": True, "description": "プロジェクト初期化、テンプレート生成"}
            },
            "language": "ja",
            "prefix": "/sg"
        }

        # 設定ディレクトリの作成
        os.makedirs(SHARED_DIR, exist_ok=True)

        # デフォルト設定を保存
        try:
            with open(CONFIG_PATH, 'w') as f:
                json.dump(default_config, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logger.error(f"設定ファイルの保存エラー: {e}")

        return default_config

# バージョン情報を表示
def show_version():
    """
    バージョン情報を表示
    """
    print(f"SuperGemini v{__version__}")
    print(f"著者: {__author__}")
    print(f"ライセンス: {__license__}")
    print(f"ホームディレクトリ: {GEMINI_HOME}")
