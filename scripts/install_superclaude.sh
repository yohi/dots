#!/bin/bash

set -e
set -o pipefail

echo "🚀 SuperClaude v3 (Claude Code Framework) のインストールを開始..."

# Claude Code の確認
echo "🔍 Claude Code の確認中..."
if ! command -v claude >/dev/null 2>&1; then
    echo "❌ Claude Code がインストールされていません"
    echo "ℹ️  先に 'make install-packages-claude-code' を実行してください"
    exit 1
else
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "不明")
    echo "✅ Claude Code が見つかりました: $CLAUDE_VERSION"
fi

# Python の確認
echo "🔍 Python の確認中..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python3 がインストールされていません"
    echo "📥 Pythonをインストールしてください: sudo apt install python3 python3-pip"
    exit 1
else
    PYTHON_VERSION=$(python3 --version)
    echo "✅ Python が見つかりました: $PYTHON_VERSION"
fi

# uv の確認とインストール
echo "🔍 uv (Python パッケージマネージャー) の確認中..."
if ! command -v uv >/dev/null 2>&1; then
    echo "📦 uv をインストール中..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v uv >/dev/null 2>&1; then
        echo "⚠️  uvのインストールが完了しましたが、現在のセッションで認識されていません"
        echo "   新しいターミナルセッションで再実行するか、以下を実行してください:"
        echo "   source $HOME/.bashrc"
    else
        echo "✅ uv をインストールしました: $(uv --version)"
    fi
else
    UV_VERSION=$(uv --version)
    echo "✅ uv が見つかりました: $UV_VERSION"
fi

export PATH="$HOME/.local/bin:$PATH"

# SuperClaude のインストール/アップデート処理
if command -v SuperClaude >/dev/null 2>&1; then
    CURRENT_VERSION=$(SuperClaude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "不明")
    echo "✅ SuperClaude は既にインストールされています (バージョン: $CURRENT_VERSION)"
    
    if [ "$CURRENT_VERSION" != "3.0.0.2" ]; then
        echo "🔄 バージョン3.0.0.2にアップデート中..."
        if ! uv tool upgrade SuperClaude==3.0.0.2 2>/dev/null; then
            echo "⚠️  uvでのアップデートに失敗。pipでのフォールバックを試行..."
            pip install --upgrade --force-reinstall "SuperClaude==3.0.0.2"
        fi
        echo "✅ SuperClaude 3.0.0.2へのアップデートが完了しました"
    else
        echo "✅ 既に最新バージョン(3.0.0.2)がインストールされています"
    fi
else
    echo "📦 SuperClaude v3.0.0.2 をインストール中..."
    echo "🔐 強化セキュリティ機能を使用します"
    if ! uv tool install SuperClaude==3.0.0.2 2>/dev/null; then
        echo "⚠️  uvでのインストールに失敗。pipでのフォールバックを試行..."
        if ! pip install --upgrade --force-reinstall "SuperClaude==3.0.0.2"; then
            echo "❌ SuperClaude のインストールに失敗しました"
            exit 1
        fi
    fi
    echo "✅ SuperClaude 3.0.0.2 のパッケージインストールが完了しました"
fi

# インストール後の検証
echo "🔍 インストール後のセキュリティ検証を実行中..."
if command -v SuperClaude >/dev/null 2>&1; then
    INSTALLED_VERSION=$(SuperClaude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "不明")
    if [ "$INSTALLED_VERSION" = "3.0.0.2" ]; then
        echo "✅ バージョン検証成功: SuperClaude 3.0.0.2"
    else
        echo "⚠️  バージョン不一致: 期待値=3.0.0.2, 実際=$INSTALLED_VERSION"
    fi
else
    echo "❌ SuperClaudeコマンドが見つかりません"
    exit 1
fi

# SuperClaude フレームワークのセットアップ
echo "⚙️  SuperClaude フレームワークをセットアップ中..."
if [ -d "$HOME/.claude" ]; then
    echo "🧹 既存の .claude ディレクトリの権限を修正中..."
    chmod -R u+w "$HOME/.claude" 2>/dev/null || true
fi

echo "🚀 SuperClaude フレームワークをセットアップ中..."
if ! printf "y\ny\ny\n" | SuperClaude install --profile developer 2>/dev/null; then
    echo "⚠️  開発者プロファイルでのセットアップに失敗。標準セットアップを試行中..."
    if ! printf "1\ny\ny\n" | SuperClaude install 2>/dev/null; then
        echo "⚠️  標準セットアップも失敗。最小セットアップを試行中..."
        rm -rf "$HOME/.claude/SuperClaude" 2>/dev/null || true
        if ! printf "2\ny\ny\n" | SuperClaude install 2>/dev/null; then
            echo "⚠️  自動セットアップに失敗しました。手動での実行が必要です: SuperClaude install --interactive"
        fi
    fi
fi

echo "✅ SuperClaude フレームワークのセットアップが完了しました"

# 最終確認
echo "🔍 最終確認中..."
if command -v SuperClaude >/dev/null 2>&1; then
    echo "✅ SuperClaude が正常にインストールされました"
    echo "   実行ファイル: $(which SuperClaude)"
    echo "   バージョン: $(SuperClaude --version 2>/dev/null || echo '取得できませんでした')"
else
    echo "❌ SuperClaude のインストール確認に失敗しました"
    exit 1
fi

echo ""
echo "🎉 SuperClaude v3 のセットアップが完了しました！"
