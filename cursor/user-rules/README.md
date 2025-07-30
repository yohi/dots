# Cursor User Rules - SuperClaude Framework

CursorのUser Rules機能で使用する、SuperClaude風のペルソナ・コマンドシステムです。

## 📁 ファイル構成

### 🔰 `basic.md` - 基本User Rules
```
用途: Cursor初心者〜中級者向け
内容: 5つのペルソナ + 16のコマンド機能
設定: Cursor → Settings → Rules → User Rules に貼り付け
```

### 🏆 `advanced.md` - エンタープライズ級User Rules
```
用途: 大規模開発・チーム開発向け
内容: 高度なペルソナ + 複合コマンド + 品質ゲート
設定: 基本ルールの代わりに、またはプロジェクト別で使用
```

### ⚡ `template.txt` - 簡単貼り付け用テンプレート
```
用途: 素早い設定・テスト用
内容: 基本ルールの簡略版
設定: 最小限の設定で即座にペルソナ機能を試せる
```

## 🚀 セットアップ方法

### 1. 基本設定（推奨）
```
1. basic.md の内容をコピー
2. Cursor → Settings → Rules → User Rules に貼り付け
3. Save して完了
```

### 2. 高度設定（チーム開発）
```
1. advanced.md の内容をコピー
2. basic.md の代わりに User Rules に設定
3. プロジェクト固有ルールも併用可能
```

### 3. クイック設定（テスト用）
```
1. template.txt の内容をコピー
2. User Rules に貼り付けて即座にテスト
3. 動作確認後、basic.md or advanced.md に移行
```

## 🎯 使用例

### ペルソナ指定
```
@architect マイクロサービス化の設計を相談したいです
@developer implement ユーザー認証機能をJWTで実装してください
@tester test 包括的なテストケースを作成してください
@devops deploy 本番環境へのデプロイ戦略を教えてください
@analyst analyze このコードのパフォーマンス改善点を見つけてください
```

### コマンド実行
```
design ECサイトのショッピングカート機能
implement 上記設計に基づいてReactコンポーネントを作成
test ショッピングカート機能のユニットテスト作成
troubleshoot デプロイ時のエラーを解決
optimize アプリケーション全体のパフォーマンス向上
```

## 🔗 関連ファイル

### 自動ペルソナ選択（Project Rules）
```
../rules/*.mdc - ファイルタイプ基づく自動ペルソナ選択
../rules/README.md - 自動選択システムの詳細説明
```

### 基本設定
```
../settings.json - Cursor基本設定
../keybindings.json - キーバインド設定
../mcp.json - MCP Tools設定
```

## 📊 User Rules vs Project Rules

| 機能         | User Rules     | Project Rules       |
| ------------ | -------------- | ------------------- |
| 適用範囲     | 全プロジェクト | プロジェクト単位    |
| ペルソナ指定 | 手動指定       | 自動選択            |
| 設定場所     | Cursor設定画面 | .cursor/rules/*.mdc |
| カスタマイズ | 中程度         | 高度                |
| 学習コスト   | 低い           | 中程度              |

## 💡 ベストプラクティス

### 1. 段階的導入
```
1. template.txt で機能確認
2. basic.md で基本ペルソナに慣れる
3. advanced.md でチーム開発対応
4. Project Rules（自動選択）も併用
```

### 2. カスタマイズ
```
- basic.md をベースに独自ルール追加
- プロジェクト固有の専門用語・制約を追記
- チーム内でルールを共有・統一
```

### 3. 効果測定
```
- ペルソナ使用前後の開発効率比較
- コード品質指標の改善確認
- チーム内のナレッジ共有促進効果
```

SuperClaudeを超える、高度なAI開発支援をCursorで実現しましょう！
