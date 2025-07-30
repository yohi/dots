# Cursor User Rules - SuperClaude Framework

CursorのUser Rules機能で使用する、SuperClaude風の統合ペルソナ・コマンドシステムです。

## 🌟 **統合機能**

**一つのUser Rulesで全機能が利用可能：**
- ✅ **手動ペルソナ指定**（`@architect として...`）
- ✅ **自動ペルソナ選択**（質問内容・ファイル種別による自動判定）
- ✅ **16種類のコマンド機能**（`implement`、`analyze`等）

## 📁 ファイル構成

```
cursor/user-rules/
├── README.md      # このファイル - 使用ガイド
├── basic.md       # 🎯 推奨：基本機能フル装備
├── advanced.md    # 🚀 上級：エンタープライズ級
├── template.txt   # ⚡ 軽量：お試し用簡易版
```

## 🚀 クイックスタート

### **ワンコマンドセットアップ（推奨）**

```bash
make setup-cursor-user-rules
```

**これだけで完了！** 手動・自動両方のペルソナ選択機能が使えます。

### **手動セットアップ**

1. ファイル内容をコピー
   ```bash
   cat ~/.config/Cursor/User/rules/basic.md
   ```

2. Cursor設定に追加
   ```
   Cursor → Settings → Rules → User Rules → + Add Rule
   Rule Name: SuperClaude Framework
   Rule Content: [コピーした内容を貼り付け]
   ```

## 💡 使用方法

### **手動ペルソナ指定**
```
@architect システム全体のマイクロサービス化を検討しています
@developer implement ユーザー認証機能をJWTで実装してください
@tester test APIエンドポイントのテストケースを作成してください
```

### **自動ペルソナ選択**
```
React最適化について教えて
→ 🎯 @developer (Frontend) として回答します

マイクロサービス分割戦略を検討したい
→ 🎯 @architect として回答します

DockerでCI/CD構築したい
→ 🎯 @devops として回答します
```

### **コマンド機能**
```
analyze このコードの問題点を教えて
implement ログイン機能を作成して
design ECサイトのアーキテクチャを設計して
```

## 🧠 自動ペルソナ選択ルール

### **ファイル種別による自動選択**
- `*.tsx`, `*.jsx`, `*.vue` → **@developer (Frontend)**
- `*.py`, `api/`, `server/` → **@developer (Backend)**
- `*.test.*`, `tests/` → **@tester**
- `Dockerfile`, `*.yaml` → **@devops**
- `architecture/`, `design/` → **@architect**

### **質問内容による自動選択**
- **設計・アーキテクチャ系** → **@architect**
- **UI・フロントエンド系** → **@developer (Frontend)**
- **API・サーバー系** → **@developer (Backend)**
- **テスト・品質系** → **@tester**
- **インフラ・運用系** → **@devops**
- **コード分析系** → **@analyst**

## 📋 ファイル詳細

### **basic.md（推奨）**
- **サイズ**: 約200行
- **内容**: 手動ペルソナ + 自動選択 + 全コマンド
- **対象**: 一般的な開発者・チーム

### **advanced.md（上級）**
- **サイズ**: 約350行
- **内容**: エンタープライズ級品質基準含む
- **対象**: 大規模プロジェクト・厳格な品質要求

### **template.txt（軽量）**
- **サイズ**: 約150行
- **内容**: 基本機能のコンパクト版
- **対象**: お試し・軽量な用途

## 🔄 Project Rules との関係

| 機能             | User Rules     | Project Rules   |
| ---------------- | -------------- | --------------- |
| 適用範囲         | **Cursor全体** | プロジェクト毎  |
| 手動ペルソナ     | ✅              | ❌               |
| 自動ペルソナ選択 | ✅              | ✅               |
| ファイル種別判定 | ✅              | ✅（より細かい） |
| 管理の簡単さ     | ✅ **簡単**     | やや複雑        |

**結論**: **User Rulesだけで十分**です。Project Rulesは特殊な要件がある場合のみ使用。

## 🛠️ トラブルシューティング

### **ペルソナが選択されない**
1. User Rulesが正しく設定されているか確認
2. Cursorを再起動
3. `make show-cursor-user-rules` で内容確認

### **設定をリセットしたい**
```bash
make clear-cursor-user-rules
make setup-cursor-user-rules
```

### **ファイルを直接編集したい**
```bash
vim ~/.config/Cursor/User/rules/basic.md
# または
code ~/.config/Cursor/User/rules/basic.md
```

## 🔗 関連ファイル

- **設定管理**: `mk/setup.mk`
- **Project Rules**: `cursor/rules/` (optional)
- **メイン設定**: `cursor/settings.json`
- **キーバインド**: `cursor/keybindings.json`

## 🎯 ベストプラクティス

1. **基本はUser Rulesのみ使用** - 管理が簡単
2. **手動指定を併用** - 明確な専門性が必要な時
3. **コマンド機能活用** - 目的に応じて `implement`、`analyze` 等
4. **定期的な更新** - `git pull` → `make setup-cursor-user-rules`

## 🌟 利用例

### **日常開発**
```
# 新機能開発
implement ユーザーダッシュボード機能をReactで作成

# バグ修正
analyze この関数でメモリリークが発生している原因を特定

# レビュー
@analyst このコードの改善点を教えて
```

### **設計フェーズ**
```
# システム設計
@architect マイクロサービス化の段階的戦略を検討

# API設計
design RESTful APIの仕様を設計して
```

### **テストフェーズ**
```
# テスト戦略
@tester 統合テストの計画を立てて

# 自動化
implement E2Eテストを Playwright で自動化
```

SuperClaude Framework for Cursor で、**効率的で専門的な開発支援**を実現しましょう！🎉
