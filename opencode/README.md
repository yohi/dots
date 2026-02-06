# 🤖 OpenCode Configuration & Pattern Switcher

OpenCode エージェントの動作設定と、モデル割り当てパターンを管理するためのディレクトリです。
コストや用途に合わせて、使用する AI モデルの組み合わせ（パターン）を簡単に切り替えることができます。

## 📂 ディレクトリ構成

```text
opencode/
├── patterns/                  # モデル割り当てパターンの定義ファイル群
│   ├── default.jsonc          # デフォルト設定
│   └── *.jsonc                # その他のパターン（コスト重視、性能重視など）
├── AGENTS.md                  # エージェント開発ガイドライン
├── oh-my-opencode.base.jsonc  # 設定ファイルのベーステンプレート
├── oh-my-opencode.jsonc       # 生成された実際の設定ファイル（このファイルが読み込まれます）
└── switch-opencode-pattern.sh # パターン切り替え用スクリプト
```

## 🔄 パターンの切り替え

`switch-opencode-pattern.sh` スクリプトを使用して、エージェント構成を対話的に切り替えることができます。

### 実行方法

```bash
./opencode/switch-opencode-pattern.sh
```

### 操作フロー

1. コマンドを実行すると、利用可能なパターンの一覧が表示されます。
2. 適用したいパターンの番号を入力します。
3. `oh-my-opencode.jsonc` が選択したパターンで上書き更新されます。

**メニュー例:**
```text
1) default - デフォルト設定
2) economy - コスト節約モード（Gemini Flash中心）
3) power - 性能重視モード（Opus/GPT-5中心）
4) 現在の設定を保存
5) 終了
番号を選択してください: 
```

## 📝 新しいパターンの作成

### 現在の設定を保存する場合
1. `oh-my-opencode.jsonc` を直接編集して好みの設定にします。
2. スクリプトを実行し、「現在の設定を保存」を選択します。
3. 名前と説明を入力すると、`patterns/` ディレクトリに新しい `.jsonc` ファイルが保存されます。

### 手動で作成する場合
1. `patterns/` ディレクトリ内に新しい `.jsonc` ファイルを作成します（例: `my-custom.jsonc`）。
2. 以下の形式で `agents` と `categories` を定義します。

```jsonc
{
  "description": "パターンの説明",
  "agents": {
    "sisyphus": { "model": "google/antigravity-gemini-3-pro" },
    // ... 他のエージェント設定
  },
  "categories": {
    "quick": { "model": "google/antigravity-gemini-3-flash" },
    // ... 他のカテゴリ設定
  }
}
```

## ⚙️ 仕組み

このシステムは、ベース設定（`oh-my-opencode.base.jsonc`）の特定の領域（マーカー間）に、パターンファイル（`patterns/*.jsonc`）の内容を注入することで機能します。

- **ベース設定**: `oh-my-opencode.base.jsonc`
  - 共通のプラグイン設定、権限設定、MCP設定などが記述されています。
  - `// @pattern:start` と `// @pattern:end` というマーカーが含まれています。

- **生成される設定**: `oh-my-opencode.jsonc`
  - OpenCode はこのファイルを参照して動作します。
  - **注意**: このファイルを直接編集しても、次回パターン切り替え時に上書きされます。恒久的な変更はベース設定かパターンファイルを編集してください。
