# Cursor自動ペルソナ選択ルール

このディレクトリには、Cursorで自動ペルソナ選択を実現する`.mdc`ファイルが含まれています。

## 📁 含まれているルールファイル

- **`architect-auto.mdc`** - アーキテクチャ・設計ファイル用
- **`developer-frontend.mdc`** - フロントエンドファイル用（React, Vue, CSS等）
- **`developer-backend.mdc`** - バックエンドファイル用（API, DB, サーバー等）
- **`tester-auto.mdc`** - テストファイル用（.test.*, .spec.*等）
- **`devops-auto.mdc`** - インフラファイル用（Docker, k8s, Terraform等）
- **`smart-persona-selector.mdc`** - AI判断型自動選択（全てのファイル対象）

## 🚀 使用方法

### 1. Makefileでのセットアップ（推奨）

```bash
# dotsプロジェクトのルートから実行
make setup-cursor-rules
```

このコマンドにより：
- プロジェクトの`.cursor/rules/`ディレクトリが作成される
- dotsの`cursor/rules/`配下の`.mdc`ファイルがシンボリックリンクされる
- Cursorで自動ペルソナ選択が有効になる

### 2. 手動セットアップ

```bash
# プロジェクトルートで実行
mkdir -p .cursor/rules
ln -sfn /path/to/dots/cursor/rules/* .cursor/rules/
```

### 3. 動作確認

以下のテストファイルを作成して動作確認：

```bash
# フロントエンド自動選択テスト
touch components/Button.tsx
# → Button.tsxを開くと @developer (Frontend) が自動適用

# バックエンド自動選択テスト
touch api/users.py
# → users.pyを開くと @developer (Backend) が自動適用

# テスト自動選択テスト
touch tests/Button.test.tsx
# → Button.test.tsxを開くと @tester が自動適用

# インフラ自動選択テスト
touch docker-compose.yml
# → docker-compose.ymlを開くと @devops が自動適用

# アーキテクチャ自動選択テスト
mkdir -p architecture && touch architecture/system-design.md
# → system-design.mdを開くと @architect が自動適用
```

## 🎯 自動選択の仕組み

### ファイルベース自動選択
ファイル拡張子やディレクトリパターンに基づいて自動選択：

- `*.tsx`, `*.jsx`, `*.vue`, `components/` → **@developer (Frontend)**
- `*.py`, `api/`, `controllers/`, `models/` → **@developer (Backend)**
- `*.test.*`, `*.spec.*`, `tests/` → **@tester**
- `Dockerfile`, `*.yml`, `k8s/`, `terraform/` → **@devops**
- `architecture/`, `design/`, `schemas/` → **@architect**

### AI判断型自動選択
質問内容を分析して最適なペルソナを自動選択：

- 「React最適化」 → **@developer (Frontend)**
- 「API設計」 → **@developer (Backend)**
- 「テスト戦略」 → **@tester**
- 「デプロイ自動化」 → **@devops**
- 「システム設計」 → **@architect**

## 🔧 カスタマイズ

### 独自ルールの追加
プロジェクト固有のルールを追加したい場合：

```bash
# プロジェクトローカルルールを作成
cat > .cursor/rules/project-specific.mdc << EOF
---
description: "プロジェクト固有ルール"
globs: ["**/custom/**"]
alwaysApply: false
---

# プロジェクト固有の専門ペルソナ

このプロジェクトの特別な要件に対応します。
EOF
```

### glob patternの調整
既存の`.mdc`ファイルの`globs`配列を編集して、対象ファイルパターンを調整可能。

## 📊 優先順位

1. **手動指定** (最優先): `@architect として...`
2. **プロジェクトローカルルール**: `.cursor/rules/project-specific.mdc`
3. **ファイルタイプベース**: `*.tsx` → Frontend等
4. **AI判断型**: 質問内容分析

## 🚨 トラブルシューティング

### ルールが適用されない場合
```bash
# Cursor再起動
pkill Cursor && cursor

# ルール確認
ls -la .cursor/rules/

# Cursor Settings → Rules → Project Rules で確認
```

### シンボリックリンクが無効な場合
```bash
# 再セットアップ
make setup-cursor-rules
```

## ✨ 効果

- **自動化**: ファイルを開くだけで適切な専門家が支援
- **一貫性**: プロジェクト全体で統一されたペルソナ適用
- **効率性**: 手動でペルソナを指定する手間を削減
- **柔軟性**: 必要に応じて手動上書きも可能

SuperClaudeを超える高度な自動ペルソナ選択をお楽しみください！
