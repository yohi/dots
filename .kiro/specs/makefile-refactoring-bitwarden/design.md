# 技術設計書

## 概要

本ドキュメントは、Makefile の構造的リファクタリング、Bitwarden CLI 連携によるセキュアな自動化フロー、および Devcontainer 内でのテスト環境構築のための技術設計を定義する。

**対象仕様:** [requirements.md](./requirements.md)  
**関連ドキュメント:**
- [architecture.md](./architecture.md) - Makefile アーキテクチャ設計書
- [devcontainer-implementation.md](./devcontainer-implementation.md) - Devcontainer 実装仕様書
- [research.md](./research.md) - ディスカバリー・リサーチログ

---

## 1. アーキテクチャパターンと境界マップ

### 1.1 システム概観

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Makefile 自動化システム                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        エントリポイント層                              │   │
│  │  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                │   │
│  │  │  Makefile   │──▶│   help.mk   │   │ shortcuts.mk│                │   │
│  │  │  (include)  │   │  (ヘルプ)    │   │  (エイリアス)│                │   │
│  │  └─────────────┘   └─────────────┘   └─────────────┘                │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                          共通基盤層                                    │   │
│  │  ┌─────────────┐   ┌─────────────┐   ┌─────────────────────────────┐│   │
│  │  │ variables.mk│   │idempotency.mk│   │deprecated-targets.mk      ││   │
│  │  │  (変数定義) │   │ (冪等性)     │   │(廃止予定ターゲット管理)     ││   │
│  │  └─────────────┘   └─────────────┘   └─────────────────────────────┘│   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        ドメイン層                                      │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐            │   │
│  │  │install.mk │ │ setup.mk  │ │ bitwarden │ │  system   │ ...        │   │
│  │  │(パッケージ)│ │ (設定)    │ │    .mk    │ │   .mk     │            │   │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘            │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        外部システム連携                                       │
│  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐           │
│  │  Bitwarden CLI  │   │   Package Mgrs   │   │   Devcontainer  │           │
│  │     (bw)        │   │ (brew, apt, npm) │   │   テスト環境     │           │
│  └─────────────────┘   └─────────────────┘   └─────────────────┘           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 境界とインターフェース

| 境界 | 説明 | インターフェース |
|------|------|-----------------|
| **エントリポイント ↔ 共通基盤** | 変数・ヘルパー関数の参照 | Makefile include ディレクティブ |
| **共通基盤 ↔ ドメイン** | 冪等性検出・廃止予定チェック | Makefile 関数・変数展開 |
| **ドメイン ↔ Bitwarden CLI** | シークレット取得 | シェル実行 (`bw` コマンド) |
| **ドメイン ↔ パッケージマネージャ** | インストール・更新 | シェル実行 (`brew`, `apt` 等) |
| **システム全体 ↔ Devcontainer** | テスト実行環境 | Docker, `devcontainer.json` |

---

## 2. 技術スタックとプロジェクト整合性

### 2.1 採用技術

| カテゴリ | 技術 | バージョン | 選定理由 |
|---------|------|-----------|---------|
| **ビルドオーケストレーション** | GNU Make | 4.3+ | 既存インフラ活用、シェルスクリプトとの親和性 |
| **シェル** | Bash/Zsh | 5.0+/5.8+ | POSIX 準拠、広範な環境サポート |
| **シークレット管理** | Bitwarden CLI | 2024.9.0+ | オープンソース、CLI ファースト、セルフホスト対応 |
| **JSON パース** | jq | 1.6+ | 軽量、広く普及、**WITH_BW=1 時は必須** |
| **コンテナ** | Docker | 24.0+ | Devcontainer 標準環境 |
| **Devcontainer ベース** | Ubuntu 22.04 LTS | - | 長期サポート、エコシステム成熟 |

### 2.2 プロジェクト既存パターンとの整合性

| 既存パターン | 本設計での適用 |
|-------------|---------------|
| **分割 Makefile (`mk/*.mk`)** | 新規ファイル（`idempotency.mk`, `bitwarden.mk`, `deprecated-targets.mk`）を追加 |
| **ハイフン区切りターゲット名** | 新規ターゲットは `{action}-{domain}-{target}` 規則に従う |
| **`.PHONY` 宣言** | 全公開ターゲットを `.PHONY` として宣言 |
| **シェルスクリプト分離 (`scripts/`)** | 複雑なロジックは `scripts/` 内のスクリプトに移譲 |
| **XDG 準拠** | マーカーファイルを `${XDG_STATE_HOME}/dots/` に配置 |

---

## 3. コンポーネントとインターフェース契約

### 3.1 コンポーネント一覧

| コンポーネント | ファイル | 責務 |
|---------------|---------|------|
| **エントリポイント** | `Makefile` | include 集約、デフォルトターゲット定義 |
| **ヘルプシステム** | `mk/help.mk` | 公開ターゲット一覧表示 |
| **短縮エイリアス** | `mk/shortcuts.mk` | 短縮エイリアスのみ定義（`i`, `s`, `h`, `s1`〜`s5` 等） |
| **廃止予定管理** | `mk/deprecated-targets.mk` | 廃止マップ、ガイダンス出力、**旧名→新名エイリアス定義** |
| **冪等性基盤** | `mk/idempotency.mk` | 冪等性検出関数・マーカー管理（**パース時副作用なし**） |
| **Bitwarden 連携** | `mk/bitwarden.mk` | 状態判定、セッション管理、シークレット取得（**jq 必須**） |
| **Devcontainer** | `.devcontainer/` | テスト環境定義 |

### 3.2 インターフェース定義

#### 3.2.1 冪等性基盤インターフェース (`mk/idempotency.mk`)

```makefile
# ============================================================
# 冪等性検出関数
# ============================================================

## マーカーファイル操作
# @param $(1) ターゲット名
# @param $(2) バージョン文字列（オプション）
define create_marker
  $(call _create_marker_impl,$(1),$(2))
endef

define check_marker
  $(call _check_marker_impl,$(1))
endef

define remove_marker
  $(call _remove_marker_impl,$(1))
endef

## バージョンチェック
# @param $(1) コマンド（例: brew --version）
# @param $(2) ツール名（例: Homebrew）
# @param $(3) 最小バージョン（例: 4.0.0）
# @return 0=満たされている, 1=未満たし
define check_min_version
  $(call _check_min_version_impl,$(1),$(2),$(3))
endef

## シンボリックリンク検証
# @param $(1) リンクパス
# @param $(2) 期待する参照先
# @return 0=一致, 1=不一致または未存在
define check_symlink
  $(call _check_symlink_impl,$(1),$(2))
endef

## コマンド存在チェック
# @param $(1) コマンド名
# @return 0=存在, 1=未存在
define check_command
  $(call _check_command_impl,$(1))
endef

# ============================================================
# 定数・設定（パース時副作用なし - ディレクトリ作成は実行時のみ）
# ============================================================
MARKER_DIR := $(or $(XDG_STATE_HOME),$(HOME)/.local/state)/dots
IDEMPOTENCY_SKIP_MSG = [SKIP] $(1) is already completed.
IDEMPOTENCY_FORCE_MSG = [FORCE] Re-running $(1).
```

**設計原則:**
- **副作用ゼロ（パース時）:** `make` / `make help` はファイルシステムを変更しない
- 全関数はシェル終了コード（0/1）を返す
- 文字列出力はエスケープ処理を施す
- 未定義変数アクセス時はエラーを返す

---

#### 3.2.2 Bitwarden 連携インターフェース (`mk/bitwarden.mk`)

```makefile
# ============================================================
# Bitwarden 連携関数
# ============================================================

## 状態判定
# @return "unlocked" | "locked" | "unauthenticated" | "not_installed" | "jq_missing" | "error"
define bw_check_status
  $(call _bw_check_status_impl)
endef

## セッションアンロック（標準出力に export 文を出力）
# @pre WITH_BW=1 が設定されていること
# @pre jq がインストールされていること
# @return 成功時: export BW_SESSION="..." を stdout に出力, exit 0
#         失敗時: エラーメッセージを stderr に出力, exit 1
.PHONY: bw-unlock
bw-unlock:
  # 実装詳細は 3.3.2 参照

## シークレット取得
# @param % アイテム名
# @pre WITH_BW=1 かつ BW_SESSION が有効
# @pre jq がインストールされていること
# @return シークレット値を stdout に出力
.PHONY: bw-get-item-%
bw-get-item-%:
  # 実装詳細は 3.3.2 参照

## Bitwarden 状態表示
.PHONY: bw-status
bw-status:
  # 人間可読な状態情報を表示

# ============================================================
# 定数・設定
# ============================================================
BW_REQUIRED_VERSION := 2024.9.0
BW_SESSION_TIMEOUT := 900  # 15分（秒）
```

**エラーハンドリング契約:**

| 条件 | 終了コード | stderr 出力 |
|------|----------|-------------|
| `WITH_BW` 未設定 | 1 | `WITH_BW=1` を指定する案内（明示オプトイン必須） |
| `jq` 未導入（WITH_BW=1時） | 1 | **jq インストール手順** |
| `bw` コマンド未導入 | 1 | インストール手順 |
| 未ログイン | 1 | `bw login` 案内 |
| セッションロック | 1 | `make bw-unlock` 案内 |
| シークレット未発見 | 1 | アイテム名と検索方法 |
| ネットワークエラー | 1 | 接続確認案内 |

---

#### 3.2.3 廃止予定管理インターフェース (`mk/deprecated-targets.mk`)

```makefile
# ============================================================
# 廃止予定ターゲット管理
# ============================================================

# マッピングフォーマット:
# OLD_TARGET:NEW_TARGET:DEPRECATION_DATE:REMOVAL_DATE:STATUS

DEPRECATED_TARGETS := \
    install-homebrew:install-packages-homebrew:2026-02-01:2026-08-01:warning \
    install-apps:install-packages-apps:2026-02-01:2026-08-01:warning \
    # ... (requirements.md §2.1 参照)

## 廃止ターゲット呼び出しハンドラ
# @param $(1) 旧ターゲット名
# @behavior 
#   - warning: 警告出力後、新ターゲットにリダイレクト
#   - transition: 警告出力後、旧動作を実行
#   - removed: エラー出力、exit 1
define handle_deprecated_target
  $(call _handle_deprecated_impl,$(1))
endef

## ヘルパー関数
define get_new_target
  $(word 2,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

define get_deprecation_status
  $(word 5,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

# ============================================================
# 環境変数
# ============================================================
# MAKE_DEPRECATION_WARN=1   -> warning/transition のガイダンス出力を有効化
# MAKE_DEPRECATION_QUIET=1  -> 警告抑制
# MAKE_DEPRECATION_STRICT=1 -> 警告をエラーとして扱う
```

---

### 3.3 詳細実装設計

#### 3.3.1 冪等性検出の実装

**requirements 対応:** 4.1〜4.7

```makefile
# mk/idempotency.mk

# ============================================================
# マーカーファイル管理
# ============================================================
# 設計原則: パース時副作用ゼロ
# - $(shell mkdir -p ...) はパース時に実行されるため使用禁止
# - ディレクトリ作成は create_marker 実行時にのみ行う
# - これにより make / make help は読み取り専用環境でも安全に動作
# ============================================================
MARKER_DIR := $(or $(XDG_STATE_HOME),$(HOME)/.local/state)/dots

# 注意: パース時にディレクトリを作成しない（副作用ゼロ原則）
# $(shell mkdir -p $(MARKER_DIR))  ← 禁止！

define _create_marker_impl
	@mkdir -p $(MARKER_DIR) && chmod 700 $(MARKER_DIR)
	@echo "# Makefile Target Completion Marker" > $(MARKER_DIR)/.done-$(1)
	@echo "# Target: $(1)" >> $(MARKER_DIR)/.done-$(1)
	@echo "# Completed: $$(date -Iseconds)" >> $(MARKER_DIR)/.done-$(1)
	@echo "# Version: $(or $(2),N/A)" >> $(MARKER_DIR)/.done-$(1)
endef

define _check_marker_impl
	@test -f $(MARKER_DIR)/.done-$(1)
endef

define _remove_marker_impl
	@rm -f $(MARKER_DIR)/.done-$(1)
endef

# ============================================================
# バージョンチェック
# ============================================================
define _check_min_version_impl
	@current_ver=$$($(1) 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1); \
	if [ -z "$$current_ver" ]; then \
		echo "[CHECK] $(2) is not installed."; \
		exit 1; \
	fi; \
	if [ $$(printf '%s\n%s\n' "$(3)" "$$current_ver" | sort -V | head -n1) = "$(3)" ]; then \
		echo "[SKIP] $(2) $$current_ver >= $(3) (satisfied)"; \
		exit 0; \
	else \
		echo "[UPDATE] $(2) $$current_ver < $(3) (needs update)"; \
		exit 1; \
	fi
endef

# ============================================================
# シンボリックリンク検証
# ============================================================
define _check_symlink_impl
	@if [ -L "$(1)" ]; then \
		actual=$$(readlink -f "$(1)"); \
		expected=$$(readlink -f "$(2)"); \
		if [ "$$actual" = "$$expected" ]; then \
			echo "[SKIP] $(1) -> $(2) (already configured)"; \
			exit 0; \
		else \
			echo "[UPDATE] $(1) points to $$actual, expected $(2)"; \
			exit 1; \
		fi; \
	elif [ -e "$(1)" ]; then \
		echo "[CONFLICT] $(1) exists but is not a symlink"; \
		exit 1; \
	else \
		exit 1; \
	fi
endef

# ============================================================
# コマンド存在チェック
# ============================================================
define _check_command_impl
	@command -v $(1) >/dev/null 2>&1
endef

# ============================================================
# 管理ターゲット
# ============================================================
.PHONY: clean-markers
clean-markers: ## 全マーカーファイルを削除（再セットアップを強制）
	@echo "[CLEAN] Removing all completion markers..."
	@rm -f $(MARKER_DIR)/.done-*
	@echo "[DONE] All markers removed. Next run will re-execute all targets."

.PHONY: clean-marker-%
clean-marker-%: ## 特定ターゲットのマーカーを削除
	@echo "[CLEAN] Removing marker for $*..."
	@rm -f $(MARKER_DIR)/.done-$*

.PHONY: check-idempotency
check-idempotency: ## 各ターゲットの冪等性状態を表示
	@echo "=== Idempotency Status ==="
	@echo ""
	@echo "Marker Files ($(MARKER_DIR)):"
	@ls -la $(MARKER_DIR)/.done-* 2>/dev/null || echo "  (no markers found)"
	@echo ""
	@echo "Package Installation Status:"
	@command -v brew >/dev/null 2>&1 && echo "  [✓] Homebrew: $$(brew --version | head -1)" || echo "  [ ] Homebrew: not installed"
	@command -v node >/dev/null 2>&1 && echo "  [✓] Node.js: $$(node --version)" || echo "  [ ] Node.js: not installed"
	@command -v bw >/dev/null 2>&1 && echo "  [✓] Bitwarden CLI: $$(bw --version)" || echo "  [ ] Bitwarden CLI: not installed"
	@echo ""
	@echo "Config Symlinks Status:"
	@test -L "$(HOME)/.zshrc" && echo "  [✓] .zshrc -> $$(readlink $(HOME)/.zshrc)" || echo "  [ ] .zshrc: not a symlink"
	@test -L "$(HOME)/.vimrc" && echo "  [✓] .vimrc -> $$(readlink $(HOME)/.vimrc)" || echo "  [ ] .vimrc: not a symlink"

# ============================================================
# FORCE フラグサポート
# ============================================================
ifdef FORCE
  SKIP_IDEMPOTENCY_CHECK := true
endif
```

---

#### 3.3.2 Bitwarden 連携の実装

**requirements 対応:** 3.1〜3.8

**設計決定: jq 必須化（WITH_BW=1 時）**

レビュー結果に基づき、`WITH_BW=1` 使用時は `jq` を必須とする。
理由：
- `bw-get-item-%` での JSON パースに jq が不可欠
- grep フォールバック実装はテスト・保守コストが高い
- CI/ローカルで同一セマンティクスを保証するため依存を統一

```makefile
# mk/bitwarden.mk

# ============================================================
# 定数
# ============================================================
BW_REQUIRED_VERSION := 2024.9.0
JQ_REQUIRED := true  # WITH_BW=1 時は jq 必須

# ============================================================
# 内部関数
# ============================================================

# jq 存在確認（WITH_BW=1 時は必須）
define _check_jq_required
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "[ERROR] jq is required for Bitwarden integration." >&2; \
		echo "        Install with: brew install jq" >&2; \
		echo "        Or: apt install jq" >&2; \
		exit 1; \
	fi
endef

# Bitwarden CLI の状態を取得
# 戻り値: unlocked, locked, unauthenticated, not_installed, jq_missing, error
# 注意: jq 必須のため、jq がない場合は jq_missing を返す
define _bw_check_status_impl
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "jq_missing"; \
	elif ! command -v bw >/dev/null 2>&1; then \
		echo "not_installed"; \
	else \
		bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"; \
	fi
endef

# ============================================================
# 公開ターゲット
# ============================================================

.PHONY: bw-unlock
bw-unlock: ## Bitwarden セッションをアンロックして BW_SESSION を出力
ifndef WITH_BW
	@echo "[WARN] Bitwarden integration is disabled." >&2
	@echo "       To enable, run with: make bw-unlock WITH_BW=1" >&2
else
	@# jq 必須チェック
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "[ERROR] jq is required for Bitwarden integration." >&2; \
		echo "        Install with: brew install jq" >&2; \
		echo "        Or: apt install jq" >&2; \
		exit 1; \
	fi
	@# 既存セッションの有効性チェック
	@if [ -n "$$BW_SESSION" ]; then \
		status=$$(BW_SESSION="$$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
		if [ "$$status" = "unlocked" ]; then \
			echo "export BW_SESSION=\"$$BW_SESSION\""; \
			exit 0; \
		fi; \
	fi
	@# bw コマンドの存在確認
	@if ! command -v bw >/dev/null 2>&1; then \
		echo "[ERROR] Bitwarden CLI (bw) is not installed." >&2; \
		echo "        Install with: brew install bitwarden-cli" >&2; \
		echo "        Or run: make install-packages-apps" >&2; \
		exit 1; \
	fi
	@# ログイン状態の確認
	@status=$$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
	if [ "$$status" = "unauthenticated" ]; then \
		echo "[ERROR] Bitwarden CLI is not logged in." >&2; \
		echo "        Run: bw login" >&2; \
		echo "        Or set BW_CLIENTID and BW_CLIENTSECRET for API key login." >&2; \
		exit 1; \
	fi
	@# アンロック実行
	@if [ -n "$$BW_PASSWORD" ]; then \
		session=$$(echo "$$BW_PASSWORD" | bw unlock --raw 2>/dev/null); \
	else \
		session=$$(bw unlock --raw 2>/dev/null); \
	fi; \
	if [ -z "$$session" ]; then \
		echo "[ERROR] Failed to unlock Bitwarden vault." >&2; \
		echo "        Check your master password and try again." >&2; \
		exit 1; \
	fi; \
	echo "export BW_SESSION=\"$$session\""
endif

.PHONY: bw-get-item-%
bw-get-item-%: ## 指定アイテムのシークレットを取得
ifndef WITH_BW
	@echo "[ERROR] Bitwarden integration is disabled." >&2
	@echo "        To enable, run with: make $@ WITH_BW=1" >&2
	@exit 1
else
	@# jq 必須チェック
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "[ERROR] jq is required for Bitwarden integration." >&2; \
		echo "        Install with: brew install jq" >&2; \
		echo "        Or: apt install jq" >&2; \
		exit 1; \
	fi
	@# セッション確認
	@if [ -z "$$BW_SESSION" ]; then \
		echo "[ERROR] Bitwarden vault is locked." >&2; \
		echo "        Run: eval \$$(make bw-unlock WITH_BW=1)" >&2; \
		echo "        Or: export BW_SESSION=\$$(bw unlock --raw)" >&2; \
		exit 1; \
	fi
	@# アイテム取得（jq 必須）
	@item=$$(BW_SESSION="$$BW_SESSION" bw get item "$*" 2>/dev/null); \
	if [ -z "$$item" ]; then \
		echo "[ERROR] Secret not found: $*" >&2; \
		echo "        Verify the item exists in your Bitwarden vault." >&2; \
		echo "        Search with: bw list items --search \"$*\"" >&2; \
		exit 1; \
	fi; \
	echo "$$item" | jq -r '.login.password // .notes // empty'
endif

.PHONY: bw-status
bw-status: ## Bitwarden CLI の状態を表示
	@echo "=== Bitwarden CLI Status ==="
	@if ! command -v bw >/dev/null 2>&1; then \
		echo "Status: NOT INSTALLED"; \
		echo "Install with: brew install bitwarden-cli"; \
	else \
		echo "CLI Version: $$(bw --version)"; \
		status=$$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "unknown"); \
		echo "Vault Status: $$status"; \
		if [ "$$status" = "unlocked" ]; then \
			email=$$(bw status 2>/dev/null | jq -r '.userEmail' 2>/dev/null); \
			echo "Logged in as: $$email"; \
		fi; \
	fi
	@echo ""
	@echo "WITH_BW flag: $${WITH_BW:-not set}"
	@echo "BW_SESSION: $$([ -n \"$$BW_SESSION\" ] && echo 'set (hidden)' || echo 'not set')"
```

---

#### 3.3.3 廃止予定ターゲット管理の実装

**requirements 対応:** 2.1〜2.4

**設計決定: エイリアス責務分離**

| ファイル | 責務 | 定義するエイリアス |
|---------|------|------------------|
| `mk/shortcuts.mk` | **短縮エイリアスのみ** | `i`, `s`, `c`, `u`, `m`, `h`, `s1`〜`s5`, `ss`, `sg` |
| `mk/deprecated-targets.mk` | **旧名→新名移行エイリアス** + 廃止管理 | `install-homebrew`→`install-packages-homebrew` 等 |

この分離により：
- 短縮エイリアス（永続維持）と旧名エイリアス（将来廃止対象）を明確に区別
- 重複定義（recipe override）のリスクを排除
- 将来のエイリアス追加時に「どこへ足すべきか」が明確

```makefile
# mk/deprecated-targets.mk

# ============================================================
# 責務: 旧ターゲット名→新ターゲット名へのエイリアス定義
#       + 廃止予定マッピング管理 + ガイダンス出力
# 
# 注意: 短縮エイリアス（i, s, h 等）は mk/shortcuts.mk で定義
# ============================================================

# ============================================================
# 廃止予定ターゲットマッピング
# フォーマット: OLD:NEW:DEPRECATION_DATE:REMOVAL_DATE:STATUS
# ============================================================
DEPRECATED_TARGETS := \
    install-homebrew:install-packages-homebrew:2026-02-01:2026-08-01:warning \
    install-apps:install-packages-apps:2026-02-01:2026-08-01:warning \
    install-deb:install-packages-deb:2026-02-01:2026-08-01:warning \
    install-flatpak:install-packages-flatpak:2026-02-01:2026-08-01:warning \
    install-fuse:install-packages-fuse:2026-02-01:2026-08-01:warning \
    install-wezterm:install-packages-wezterm:2026-02-01:2026-08-01:warning \
    install-cursor:install-packages-cursor:2026-02-01:2026-08-01:warning \
    install-claude-code:install-packages-claude-code:2026-02-01:2026-08-01:warning \
    install-cica-fonts:install-packages-cica-fonts:2026-02-01:2026-08-01:warning \
    install-mysql-workbench:install-packages-mysql-workbench:2026-02-01:2026-08-01:warning \
    install-chrome-beta:install-packages-chrome-beta:2026-02-01:2026-08-01:warning \
    install-playwright:install-packages-playwright:2026-02-01:2026-08-01:warning \
    install-clipboard:install-packages-clipboard:2026-02-01:2026-08-01:warning \
    install-gemini-cli:install-packages-gemini-cli:2026-02-01:2026-08-01:warning \
    setup-vim:setup-config-vim:2026-02-01:2026-08-01:warning \
    setup-zsh:setup-config-zsh:2026-02-01:2026-08-01:warning \
    setup-wezterm:setup-config-wezterm:2026-02-01:2026-08-01:warning \
    setup-vscode:setup-config-vscode:2026-02-01:2026-08-01:warning \
    setup-cursor:setup-config-cursor:2026-02-01:2026-08-01:warning \
    setup-git:setup-config-git:2026-02-01:2026-08-01:warning \
    setup-docker:setup-config-docker:2026-02-01:2026-08-01:warning \
    setup-ime:setup-config-ime:2026-02-01:2026-08-01:warning \
    setup-claude:setup-config-claude:2026-02-01:2026-08-01:warning \
    setup-all:setup-config-all:2026-02-01:2026-08-01:warning

# ============================================================
# ヘルパー関数
# ============================================================
define get_new_target
$(word 2,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

define get_removal_date
$(word 4,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

define get_deprecation_status
$(word 5,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

# ============================================================
# 廃止予定ターゲットガイダンス出力
# ============================================================
define deprecation_warning
	@if [ "$(MAKE_DEPRECATION_STRICT)" = "1" ]; then \
		echo "[DEPRECATED] Target '$(1)' is deprecated and treated as error (MAKE_DEPRECATION_STRICT=1)." >&2; \
		echo "             Use '$(2)' instead." >&2; \
		echo "             Migration: make $(2)" >&2; \
		exit 1; \
	fi
	@if [ "$(MAKE_DEPRECATION_WARN)" = "1" ] && [ "$(MAKE_DEPRECATION_QUIET)" != "1" ]; then \
		echo "[DEPRECATED] Target '$(1)' is deprecated and will be removed on $(3)." >&2; \
		echo "             Use '$(2)' instead." >&2; \
		echo "             Migration: make $(2)" >&2; \
	fi
endef

define deprecation_error
	@echo "[ERROR] Target '$(1)' has been removed as of $(3)." >&2
	@echo "        Use '$(2)' instead." >&2
	@echo "        Run: make $(2)" >&2
	@exit 1
endef

# ============================================================
# 旧名→新名エイリアス（本ファイルで集中管理）
# ============================================================
# 注: デフォルトでは警告なしでエイリアスとして動作（後方互換性優先）。
# - MAKE_DEPRECATION_WARN=1 で warning/transition のガイダンスを有効化
# - MAKE_DEPRECATION_STRICT=1 で warning/transition をエラー扱い（exit 1）

# パッケージインストール系
.PHONY: install-homebrew
install-homebrew: install-packages-homebrew

.PHONY: install-apps
install-apps: install-packages-apps

.PHONY: install-deb
install-deb: install-packages-deb

.PHONY: install-flatpak
install-flatpak: install-packages-flatpak

.PHONY: install-fuse
install-fuse: install-packages-fuse

.PHONY: install-wezterm
install-wezterm: install-packages-wezterm

.PHONY: install-cursor
install-cursor: install-packages-cursor

.PHONY: install-claude-code
install-claude-code: install-packages-claude-code

.PHONY: install-cica-fonts
install-cica-fonts: install-packages-cica-fonts

.PHONY: install-mysql-workbench
install-mysql-workbench: install-packages-mysql-workbench

.PHONY: install-chrome-beta
install-chrome-beta: install-packages-chrome-beta

.PHONY: install-playwright
install-playwright: install-packages-playwright

.PHONY: install-clipboard
install-clipboard: install-packages-clipboard

.PHONY: install-gemini-cli
install-gemini-cli: install-packages-gemini-cli

# 設定セットアップ系
.PHONY: setup-vim
setup-vim: setup-config-vim

.PHONY: setup-zsh
setup-zsh: setup-config-zsh

.PHONY: setup-wezterm
setup-wezterm: setup-config-wezterm

.PHONY: setup-vscode
setup-vscode: setup-config-vscode

.PHONY: setup-cursor
setup-cursor: setup-config-cursor

.PHONY: setup-git
setup-git: setup-config-git

.PHONY: setup-docker
setup-docker: setup-config-docker

.PHONY: setup-ime
setup-ime: setup-config-ime

.PHONY: setup-claude
setup-claude: setup-config-claude

.PHONY: setup-all
setup-all: setup-config-all

# GNOME 系
.PHONY: gnome-settings
gnome-settings: setup-gnome-settings

.PHONY: gnome-extensions
gnome-extensions: setup-gnome-extensions

.PHONY: gnome-tweaks
gnome-tweaks: setup-gnome-tweaks

.PHONY: setup-mozc
setup-mozc: setup-config-mozc

# AI 開発ツール系
.PHONY: claudecode
claudecode: superclaude-install

.PHONY: cc-sdd
cc-sdd: cc-sdd-install
```

---

#### 3.3.3a 短縮エイリアスの定義 (`mk/shortcuts.mk`)

```makefile
# mk/shortcuts.mk

# ============================================================
# 責務: 短縮エイリアスのみ定義（永続維持、廃止対象外）
#
# 注意: 旧名→新名エイリアスは mk/deprecated-targets.mk で定義
# ============================================================

# 基本操作
.PHONY: i
i: install

.PHONY: s
s: setup

.PHONY: c
c: check-cursor-version

.PHONY: u
u: update-cursor

.PHONY: m
m: menu

.PHONY: h
h: help

# 段階的セットアップ
.PHONY: s1
s1: stage1

.PHONY: s2
s2: stage2

.PHONY: s3
s3: stage3

.PHONY: s4
s4: stage4

.PHONY: s5
s5: stage5

.PHONY: ss
ss: stage-status

.PHONY: sg
sg: stage-guide
```

---

#### 3.3.4 エントリポイントとヘルプシステム

**requirements 対応:** 1.1〜1.4

```makefile
# Makefile (更新後)

# Ubuntu開発環境セットアップ用Makefile

# 共通基盤
include mk/variables.mk
include mk/idempotency.mk
include mk/deprecated-targets.mk

# ヘルプ・エイリアス
include mk/help.mk
include mk/help-short.mk
include mk/shortcuts.mk

# Bitwarden 連携
include mk/bitwarden.mk

# テスト
include mk/test.mk

# ドメイン別
include mk/system.mk
include mk/fonts.mk
include mk/install.mk
include mk/setup.mk
include mk/gnome.mk
include mk/mozc.mk
include mk/extensions.mk
include mk/clipboard.mk
include mk/sticky-keys.mk
include mk/clean.mk
include mk/main.mk
include mk/menu.mk
include mk/memory.mk
include mk/codex.mk
include mk/superclaude.mk
include mk/cc-sdd.mk

# デフォルトターゲットを help に変更
.PHONY: all
all: help
```

---

### 3.4 Devcontainer コンポーネント

**requirements 対応:** 5.1〜5.5  
**詳細仕様:** [devcontainer-implementation.md](./devcontainer-implementation.md)

#### ファイル構造

```
.devcontainer/
├── Dockerfile
├── devcontainer.json
├── mocks/
│   └── bw                # モック Bitwarden CLI（PATH で bw を上書き）
└── scripts/
    ├── post-create.sh    # コンテナ作成後の初期化
    ├── post-start.sh     # コンテナ起動時チェック
    ├── bw-keepalive.sh   # セッションキープアライブ
    └── check-host-prerequisites.sh  # ホスト環境検証
```

#### テストターゲット

```makefile
# mk/test.mk

.PHONY: test
test: ## 全テスト実行
	@echo "Running all tests..."
	@$(MAKE) test-unit
	@$(MAKE) test-bw-mock

.PHONY: test-unit
test-unit: ## ユニットテスト実行
	@echo "Running unit tests..."
	# 冪等性検出テスト
	@$(MAKE) check-idempotency

.PHONY: test-bw-mock
test-bw-mock: ## Bitwarden モックテスト実行
	@echo "Running Bitwarden mock tests..."
	@PATH=".devcontainer/mocks:$$PATH" $(MAKE) bw-status WITH_BW=1

.PHONY: test-bw-integration
test-bw-integration: ## Bitwarden 統合テスト実行（BW_SESSION 必須）
ifndef BW_SESSION
	@echo "[ERROR] BW_SESSION is required for integration tests." >&2
	@echo "        Run: eval \$$(make bw-unlock WITH_BW=1)" >&2
	@exit 1
endif
	@echo "Running Bitwarden integration tests..."
	@$(MAKE) bw-status WITH_BW=1

.PHONY: check-deps
check-deps: ## 依存関係の検証
	@echo "Checking dependencies..."
	@command -v make >/dev/null 2>&1 && echo "[✓] make" || echo "[✗] make"
	@command -v git >/dev/null 2>&1 && echo "[✓] git" || echo "[✗] git"
	@# jq は WITH_BW=1 時は必須
	@if [ "$${WITH_BW:-0}" = "1" ]; then \
		command -v jq >/dev/null 2>&1 && echo "[✓] jq (required for WITH_BW=1)" || echo "[✗] jq (REQUIRED for WITH_BW=1)"; \
	else \
		command -v jq >/dev/null 2>&1 && echo "[✓] jq" || echo "[ ] jq (optional)"; \
	fi
	@command -v bw >/dev/null 2>&1 && echo "[✓] bw" || echo "[ ] bw (optional)"

.PHONY: test-setup
test-setup: ## テスト用モックデータのセットアップ
	@mkdir -p .devcontainer/mocks
	@chmod +x .devcontainer/mocks/bw 2>/dev/null || true
	@echo "[DONE] Test setup complete"
```

---

## 4. データフロー

### 4.1 Bitwarden シークレット取得フロー

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Bitwarden シークレット取得フロー                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ユーザー                                                                    │
│     │                                                                        │
│     │ make install WITH_BW=1                                                │
│     ▼                                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ Makefile                                                             │    │
│  │   │                                                                  │    │
│  │   │ WITH_BW=1 チェック                                               │    │
│  │   ▼                                                                  │    │
│  │ ┌─────────────────────────────────────────────────────────────────┐ │    │
│  │ │ bitwarden.mk                                                    │ │    │
│  │ │   │                                                             │ │    │
│  │ │   │ 1. bw status (状態判定)                                     │ │    │
│  │ │   │    └── JSON 解析 (jq / grep)                                │ │    │
│  │ │   │                                                             │ │    │
│  │ │   │ 2. 状態分岐                                                 │ │    │
│  │ │   │    ├── unlocked → シークレット取得へ                        │ │    │
│  │ │   │    ├── locked → エラー + bw-unlock 案内                     │ │    │
│  │ │   │    ├── unauthenticated → エラー + bw login 案内             │ │    │
│  │ │   │    └── not_installed → エラー + インストール案内            │ │    │
│  │ │   │                                                             │ │    │
│  │ │   │ 3. bw get item <name> (シークレット取得)                    │ │    │
│  │ │   │    └── BW_SESSION 環境変数を使用                            │ │    │
│  │ │   │                                                             │ │    │
│  │ │   │ 4. シークレット値を環境変数として export                    │ │    │
│  │ │   │    └── ログに出力しない                                     │ │    │
│  │ │   ▼                                                             │ │    │
│  │ └─────────────────────────────────────────────────────────────────┘ │    │
│  │   │                                                                  │    │
│  │   │ 後続ターゲット実行                                               │    │
│  │   ▼                                                                  │    │
│  │ ┌─────────────────────────────────────────────────────────────────┐ │    │
│  │ │ install.mk / setup.mk                                           │ │    │
│  │ │   シークレットを使用した設定処理                                 │ │    │
│  │ └─────────────────────────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 冪等性チェックフロー

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        冪等性チェックフロー                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  make <target> [FORCE=1]                                                    │
│     │                                                                        │
│     ▼                                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ FORCE=1 チェック                                                     │    │
│  │   │                                                                  │    │
│  │   ├── FORCE=1 → スキップ、実行へ                                     │    │
│  │   │                                                                  │    │
│  │   └── FORCE 未設定 → 冪等性チェック                                  │    │
│  │         │                                                            │    │
│  │         ▼                                                            │    │
│  │   ┌─────────────────────────────────────────────────────────────┐   │    │
│  │   │ ターゲット別検出メソッド                                     │   │    │
│  │   │                                                             │   │    │
│  │   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │   │    │
│  │   │  │ FILE_EXISTS │  │VERSION_CHECK│  │ MARKER_FILE │ ...    │   │    │
│  │   │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │   │    │
│  │   │         │                │                │                │   │    │
│  │   │         ▼                ▼                ▼                │   │    │
│  │   │      ファイル/       バージョン       マーカー            │   │    │
│  │   │      リンク確認      比較             ファイル確認         │   │    │
│  │   └─────────────────────────────────────────────────────────────┘   │    │
│  │         │                                                            │    │
│  │         ▼                                                            │    │
│  │   ┌─────────────────────────────────────────────────────────────┐   │    │
│  │   │ 結果判定                                                     │   │    │
│  │   │   │                                                         │   │    │
│  │   │   ├── 満たされている → [SKIP] メッセージ → exit 0          │   │    │
│  │   │   │                                                         │   │    │
│  │   │   └── 未満たし → 実際のターゲット処理を実行                 │   │    │
│  │   │                    │                                        │   │    │
│  │   │                    ▼                                        │   │    │
│  │   │                成功時: マーカーファイル作成                  │   │    │
│  │   │                        (MARKER_FILE メソッドの場合)          │   │    │
│  │   └─────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. 要件トレーサビリティマトリクス

| 要件ID | 要件概要 | コンポーネント | 検証方法 |
|--------|---------|---------------|---------|
| 1.1 | デフォルトエントリポイント明確化 | Makefile | `make` 実行でヘルプ表示確認、**副作用ゼロ確認** |
| 1.2 | 公開ターゲット定義 | mk/help.mk | `make help` 出力確認 |
| 1.3 | エイリアスポリシー | mk/shortcuts.mk（短縮）, mk/deprecated-targets.mk（旧名） | `make i` 等で動作確認 |
| 1.4 | 命名規則統一 | 各 `mk/*.mk` | ターゲット名レビュー |
| 2.1 | 廃止予定マップ | mk/deprecated-targets.mk | マッピング定義確認 |
| 2.2 | ガイダンス出力 | mk/deprecated-targets.mk | stderr 出力確認 |
| 2.3 | タイムラインポリシー | mk/deprecated-targets.mk | 日付フィールド確認 |
| 2.4 | 廃止予定ターゲット管理 | mk/deprecated-targets.mk | `MAKE_DEPRECATION_QUIET/STRICT` テスト |
| 2.5-2.8 | WITH_BW フラグ | mk/bitwarden.mk | `WITH_BW=1` 有無での動作差異確認 |
| 3.1 | ターゲット別動作差分 | mk/bitwarden.mk | 各ターゲットのフラグ依存動作確認 |
| 3.2 | フォールバック動作 | mk/bitwarden.mk | 各条件でのエラーメッセージ確認 |
| 3.3 | シナリオ別エラー | mk/bitwarden.mk | エラーメッセージ・終了コード確認 |
| 3.4-3.6 | BW_SESSION 永続化 | mk/bitwarden.mk | `eval $(make bw-unlock)` テスト |
| 3.7 | 状態判定ロジック | mk/bitwarden.mk | `bw status` 解析テスト |
| 3.8 | bw-unlock 実装 | mk/bitwarden.mk | セッション取得テスト |
| 4.1-4.3 | 冪等性検出メソッド | mk/idempotency.mk | 各メソッドの単体テスト |
| 4.4-4.5 | バージョン/ファイルチェック | mk/idempotency.mk | ヘルパー関数テスト |
| 4.6-4.7 | クリーンアップ/検証ルール | mk/idempotency.mk | `clean-markers`, `check-idempotency` テスト |
| 5.1 | ベースイメージ | .devcontainer/Dockerfile | イメージビルド確認 |
| 5.2 | Bitwarden CLI インストール | .devcontainer/Dockerfile | コンテナ内 `bw --version` 確認 |
| 5.3 | クレデンシャル提供 | .devcontainer/devcontainer.json | 環境変数フォワード確認 |
| 5.4 | 自動テストブートストラップ | .devcontainer/scripts/ | `postCreateCommand` 実行確認 |
| 5.5 | テストの受け入れ基準 | mk/test.mk | `make test`, `test-bw-mock` 実行 |

---

## 6. セキュリティ考慮事項

### 6.1 シークレット保護

| 脅威 | 対策 |
|------|------|
| セッションキーのログ出力 | stdout/stderr への出力禁止、`--raw` オプション使用 |
| シェル履歴への保存 | `eval $()` パターンで直接展開、履歴非保存 |
| ファイルシステム永続化 | マーカーファイルにシークレット不含、セッションファイル非推奨 |
| プロセスリストへの露出 | マスターパスワードを引数として渡さない |

### 6.2 アクセス制御

| リソース | 保護方式 |
|---------|---------|
| マーカーディレクトリ | ユーザー権限のみ (`700`) |
| Devcontainer 内シークレット | `remoteEnv` 経由、コンテナ再起動で消去 |
| CI シークレット | GitHub Actions Secrets 経由 |

---

## 7. パフォーマンス考慮事項

### 7.1 冪等性チェック最適化

| 操作 | 推奨メソッド | 理由 |
|------|-------------|------|
| 頻繁に呼ばれるターゲット | `FILE_EXISTS`, `COMMAND_CHECK` | 軽量なファイルシステム/コマンド確認 |
| 複合セットアップ | `MARKER_FILE` | 単一ファイル確認で複数処理の完了を判定 |
| バージョン依存更新 | `VERSION_CHECK` | 正確なバージョン比較が必要な場合のみ |

### 7.2 Bitwarden API 呼び出し削減

- `BW_SESSION` が有効な場合は再アンロックをスキップ
- `bw sync` はセッション延長目的で最小限に使用
- 複数シークレット取得時は一括取得を検討（将来拡張）

---

## 8. 制約事項

### 8.1 依存関係

| 依存 | 最小バージョン | 必須/オプション |
|------|---------------|----------------|
| GNU Make | 4.3 | 必須 |
| Bash | 5.0 | 必須 |
| jq | 1.6 | **WITH_BW=1 使用時は必須**（それ以外はオプション） |
| Bitwarden CLI | 2024.9.0 | WITH_BW=1 使用時必須 |
| Docker | 24.0 | Devcontainer 使用時必須 |

### 8.2 環境制限

- **Windows 非対応:** WSL2 経由での使用を推奨
- **古い Ubuntu:** 20.04 以降をサポート、18.04 は非サポート
- **セルフホスト Bitwarden:** `BW_SERVER` 環境変数で対応可能だが、テスト対象外

---

## 9. 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|-----|---------|
| 1.0 | 2026-01-06 | 初版作成 - アーキテクチャ、コンポーネント設計、インターフェース契約を定義 |
| 1.1 | 2026-01-06 | デザインレビュー対応 - (1) パース時副作用排除、(2) jq 必須化（WITH_BW=1時）、(3) エイリアス責務分離ルール明確化 |
