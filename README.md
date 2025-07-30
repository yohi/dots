# 🚀 SuperClaude Framework for Cursor

Cursor向けに最適化されたSuperClaude Framework風の開発支援ルールセットです。

## 📖 概要

このプロジェクトは、[SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)の機能をCursorのUser Rulesとして再現し、高度なAI駆動開発を実現します。

### ✨ 主な機能

- 🎭 **5つの専門ペルソナ**: アーキテクト、アナリスト、デベロッパー、テスター、DevOpsエンジニア
- 🛠️ **16のコマンド機能**: analyze、implement、design、test、troubleshoot等
- 📋 **ワークフロー統合**: プロジェクト全体の開発プロセス支援
- 🔒 **品質ゲート**: コード品質とセキュリティの自動チェック
- 🏗️ **アーキテクチャガイダンス**: スケーラブルな設計の支援

## 🚀 クイックスタート

### 1. ルールファイルをダウンロード
```bash
# このリポジトリをクローンまたはファイルをダウンロード
git clone <このリポジトリのURL>
```

### 2. Cursorに設定を適用

#### 基本設定（推奨）
1. Cursor → Settings → Rules
2. User Rulesタブを開く
3. `cursor/user-rules/basic.md`の内容をコピー&ペースト

#### 高度な設定（上級者向け）
- 基本設定の代わりに`cursor/user-rules/advanced.md`の内容を使用

#### 自動ペルソナ選択（最新機能）
```bash
# dotsプロジェクトから自動ペルソナ選択を適用
make setup-cursor-rules
```

### 3. 即座に使用開始
```
@developer implement
React + TypeScript でTODOアプリを作成してください。
```

## 📁 ファイル構成

```
📂 dots/
├── 📄 README.md                          # このファイル
├── 📂 cursor/
│   ├── 📂 user-rules/                    # User Rules（手動指定ペルソナ）
│   │   ├── 📄 README.md                  # User Rules使用ガイド
│   │   ├── 📄 basic.md                   # 基本ルールセット
│   │   ├── 📄 advanced.md                # エンタープライズ級ルールセット
│   │   └── 📄 template.txt               # 簡単貼り付け用テンプレート
│   ├── 📂 rules/                         # Project Rules（自動ペルソナ選択）
│   │   ├── 📄 README.md                  # 自動選択システムガイド
│   │   ├── 📄 *.mdc                      # 自動ペルソナ選択ルール
│   │   └── 📄 smart-persona-selector.mdc # AI判断型自動選択
│   ├── 📄 settings.json                  # Cursor基本設定
│   ├── 📄 keybindings.json               # キーバインド設定
│   └── 📄 mcp.json                       # MCP Tools設定
└── 📂 mk/
    └── 📄 setup.mk                       # make setup-cursor-rules
```

## 🎯 使用例

### ペルソナ切り替え方式
```
@architect システム全体の設計を検討したいです
@developer 認証機能を実装してください
@tester 単体テストを作成してください
@analyst コードをレビューしてください
@devops デプロイメント戦略を教えてください
```

### コマンド方式
```
design ECサイトの設計をしてください
implement ショッピングカート機能
test 実装されたAPIのテストケース作成
troubleshoot エラーの原因を特定してください
optimize パフォーマンスを改善してください
```

### 複合使用
```
@architect design
マイクロサービスアーキテクチャでECサイトを設計し、
その後各サービスの実装方針も検討してください。
```

## 🛠️ 対応分野

### フロントエンド
- React/Vue/Angular
- TypeScript/JavaScript
- Web標準（HTML/CSS）
- パフォーマンス最適化
- アクセシビリティ

### バックエンド
- Node.js/Python/Java/.NET
- API設計（REST/GraphQL）
- データベース設計
- セキュリティ実装
- スケーラビリティ

### インフラ・DevOps
- AWS/Azure/GCP
- Docker/Kubernetes
- CI/CD
- Infrastructure as Code
- 監視・ログ管理

### モバイル
- React Native/Flutter
- iOS/Android ネイティブ
- パフォーマンス最適化
- ストア最適化

### 機械学習・AI
- データパイプライン
- MLOps
- モデル最適化
- プライバシー保護

## 📚 ドキュメント

### 基本利用
- [セットアップガイド](cursor-superclaude-setup-guide.md) - 詳細な設定手順
- [基本ルール](cursor-superclaude-rules.md) - 基本的な機能とペルソナ

### 上級利用
- [高度なルール](cursor-superclaude-advanced.md) - 専門的機能と品質ゲート

## 🎓 ベストプラクティス

### 効果的な質問の仕方
1. **具体的なコンテキスト**: 技術スタック、環境、制約を明示
2. **明確な目標**: 何を達成したいかを具体的に
3. **現在の状況**: 既存コード、エラー、問題点を詳細に
4. **期待する結果**: 求める出力形式、詳細レベルを指定

### ペルソナ選択ガイド
- **設計・アーキテクチャ** → `@architect`
- **実装・コーディング** → `@developer`
- **コード分析・改善** → `@analyst`
- **テスト・品質保証** → `@tester`
- **インフラ・運用** → `@devops`

## 🔄 ワークフロー例

### 新機能開発
```
1. @architect design [機能要件]
2. @developer implement [設計に基づく実装]
3. @tester test [実装されたコードのテスト]
4. @analyst review [コード品質チェック]
5. @devops deploy [デプロイメント戦略]
```

### 既存コード改善
```
1. @analyst analyze [既存コード分析]
2. @architect refactor [リファクタリング設計]
3. @developer improve [改善実装]
4. @tester test [回帰テスト]
```

## 🆚 SuperClaude Framework vs Cursor版

| 項目               | SuperClaude Framework         | Cursor版                 |
| ------------------ | ----------------------------- | ------------------------ |
| 対象               | Claude Code専用               | Cursor専用               |
| 設定方法           | Python パッケージインストール | User Rules設定           |
| スラッシュコマンド | `/sc:command` 形式            | コマンドキーワード形式   |
| MCP統合            | 対応                          | 未対応（User Rules制約） |
| カスタマイズ       | 高度な設定可能                | ルール編集で対応         |
| 学習コスト         | 中程度                        | 低い                     |

## 🤝 コントリビューション

改善提案や新機能のアイデアがありましたら、お気軽にIssueまたはPull Requestを作成してください。

### 改善例
- 新しいペルソナの追加
- 特定分野の専門ルール
- ワークフロー最適化
- 使用例の追加

## 📜 ライセンス

MITライセンス - 詳細は[LICENSE](LICENSE)ファイルを参照

## 🙏 謝辞

本プロジェクトは[SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)からインスパイアされました。素晴らしいフレームワークを開発・公開してくださったSuperClaude-Orgチームに感謝いたします。

---

**⚡ 今すぐ始める**: `cursor-superclaude-rules.md`をUser Rulesにコピペして、AI駆動開発を体験してください！
