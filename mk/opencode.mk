# ============================================================
# OpenCode (opencode): インストール・設定
# ============================================================

OPENCODE_HOME ?= $(HOME_DIR)/.opencode
OPENCODE_BIN ?= $(OPENCODE_HOME)/bin/opencode
OPENCODE_CONFIG_DIR ?= $(CONFIG_DIR)/opencode
OPENCODE_CONFIG_PATH ?= $(OPENCODE_CONFIG_DIR)/opencode.jsonc
OPENCODE_DOTFILES_CONFIG ?= $(DOTFILES_DIR)/opencode/opencode.jsonc
OH_MY_OPENCODE_CONFIG_PATH ?= $(OPENCODE_CONFIG_DIR)/oh-my-opencode.jsonc
OH_MY_OPENCODE_DOTFILES_CONFIG ?= $(DOTFILES_DIR)/opencode/oh-my-opencode.jsonc

.PHONY: opencode opencode-install opencode-update setup-opencode check-opencode

# OpenCode (opencode) をインストール & 設定
opencode: ## OpenCode（opencode）のインストールとセットアップ
	@if [ -x "$(OPENCODE_BIN)" ] && [ -f "$(OPENCODE_DOTFILES_CONFIG)" ] && [ -L "$(OPENCODE_CONFIG_PATH)" ]; then \
		actual=$$(readlink -f "$(OPENCODE_CONFIG_PATH)" 2>/dev/null || true); \
		expected=$$(readlink -f "$(OPENCODE_DOTFILES_CONFIG)" 2>/dev/null || true); \
		if [ "$$actual" = "$$expected" ]; then \
			skip=1; \
			if [ -f "$(OH_MY_OPENCODE_DOTFILES_CONFIG)" ]; then \
				if [ -L "$(OH_MY_OPENCODE_CONFIG_PATH)" ]; then \
					actual_oh=$$(readlink -f "$(OH_MY_OPENCODE_CONFIG_PATH)" 2>/dev/null || true); \
					expected_oh=$$(readlink -f "$(OH_MY_OPENCODE_DOTFILES_CONFIG)" 2>/dev/null || true); \
					if [ "$$actual_oh" != "$$expected_oh" ]; then skip=0; fi; \
				else skip=0; fi; \
			fi; \
			if [ "$$skip" = "1" ]; then \
				echo "$(call IDEMPOTENCY_SKIP_MSG,opencode)"; \
				exit 0; \
			fi; \
		fi; \
	fi; \
	$(MAKE) opencode-install setup-opencode

# OpenCode をインストール（公式インストーラ）
opencode-install: ## OpenCode（opencode）をインストール
	@echo "📦 OpenCode（opencode）をインストール中..."
	@if [ -x "$(OPENCODE_BIN)" ]; then \
		echo "[SKIP] opencode is already installed: $(OPENCODE_BIN)"; \
		exit 0; \
	fi
	@if ! command -v curl >/dev/null 2>&1; then \
		echo "❌ curl が見つかりません。先に curl をインストールしてください"; \
		exit 1; \
	fi
	@bash -c 'set -euo pipefail; tmp="$$(mktemp)"; curl -fsSL https://opencode.ai/install -o "$$tmp"; bash "$$tmp"; rm -f "$$tmp"'
	@if [ ! -x "$(OPENCODE_BIN)" ]; then \
		echo "❌ opencode のインストールに失敗しました: $(OPENCODE_BIN) が見つかりません"; \
		exit 1; \
	fi
	@echo "✅ OpenCode（opencode）のインストールが完了しました"
	@$(call create_marker,opencode-install,$$($(OPENCODE_BIN) --version 2>/dev/null || echo unknown))

# OpenCode を更新（公式インストーラ再実行）
opencode-update: ## OpenCode（opencode）をアップデート
	@echo "📦 OpenCode（opencode）をアップデート中..."
	@if ! command -v curl >/dev/null 2>&1; then \
		echo "❌ curl が見つかりません。先に curl をインストールしてください"; \
		exit 1; \
	fi
	@bash -c 'set -euo pipefail; tmp="$$(mktemp)"; curl -fsSL https://opencode.ai/install -o "$$tmp"; bash "$$tmp"; rm -f "$$tmp"'
	@if [ -x "$(OPENCODE_BIN)" ]; then \
		echo "✅ 更新後のバージョン: $$($(OPENCODE_BIN) --version 2>/dev/null || echo unknown)"; \
	fi
	@$(call create_marker,opencode-update,$$($(OPENCODE_BIN) --version 2>/dev/null || echo unknown))

# OpenCode の設定を適用（XDG config へシンボリックリンク）
setup-opencode: ## OpenCode（opencode）の設定ファイルを適用
	@echo "🔧 OpenCode（opencode）の設定を適用中..."
	@mkdir -p "$(OPENCODE_CONFIG_DIR)"
	@# opencode.jsonc の設定
	@if [ ! -f "$(OPENCODE_DOTFILES_CONFIG)" ]; then \
		echo "⚠️  設定ファイルが見つかりません: $(OPENCODE_DOTFILES_CONFIG)"; \
		echo "    先に dotfiles に設定ファイルを用意してください"; \
		exit 1; \
	fi
	@if [ -e "$(OPENCODE_CONFIG_PATH)" ] && [ ! -L "$(OPENCODE_CONFIG_PATH)" ]; then \
		backup="$(OPENCODE_CONFIG_PATH).bak.$$(date +%Y%m%d%H%M%S)"; \
		echo "⚠️  既存の設定ファイルを退避します: $$backup"; \
		mv "$(OPENCODE_CONFIG_PATH)" "$$backup"; \
	fi
	@ln -sfn "$(OPENCODE_DOTFILES_CONFIG)" "$(OPENCODE_CONFIG_PATH)"
	@echo "✅ 設定を適用しました: $(OPENCODE_CONFIG_PATH)"
	@# oh-my-opencode.jsonc の設定
	@if [ -f "$(OH_MY_OPENCODE_DOTFILES_CONFIG)" ]; then \
		if [ -e "$(OH_MY_OPENCODE_CONFIG_PATH)" ] && [ ! -L "$(OH_MY_OPENCODE_CONFIG_PATH)" ]; then \
			backup="$(OH_MY_OPENCODE_CONFIG_PATH).bak.$$(date +%Y%m%d%H%M%S)"; \
			echo "⚠️  既存の oh-my-opencode 設定ファイルを退避します: $$backup"; \
			mv "$(OH_MY_OPENCODE_CONFIG_PATH)" "$$backup"; \
		fi; \
		ln -sfn "$(OH_MY_OPENCODE_DOTFILES_CONFIG)" "$(OH_MY_OPENCODE_CONFIG_PATH)"; \
		echo "✅ 設定を適用しました: $(OH_MY_OPENCODE_CONFIG_PATH)"; \
	else \
		echo "ℹ️  oh-my-opencode 設定ファイルはスキップされました（見つかりません）"; \
	fi
	@$(call create_marker,setup-opencode,1)

# OpenCode の状態確認
check-opencode: ## OpenCode（opencode）の状態を確認
	@echo "🔍 OpenCode（opencode）の状態確認..."
	@if [ -x "$(OPENCODE_BIN)" ]; then \
		echo "✅ opencode: $$($(OPENCODE_BIN) --version 2>/dev/null || echo unknown)"; \
	else \
		echo "⚠️  opencode が見つかりません: $(OPENCODE_BIN)"; \
	fi
	@if [ -L "$(OPENCODE_CONFIG_PATH)" ]; then \
		actual=$$(readlink -f "$(OPENCODE_CONFIG_PATH)" 2>/dev/null || readlink "$(OPENCODE_CONFIG_PATH)" 2>/dev/null || true); \
		expected=$$(readlink -f "$(OPENCODE_DOTFILES_CONFIG)" 2>/dev/null || true); \
		if [ -n "$$actual" ] && [ "$$actual" = "$$expected" ]; then \
			echo "✅ config: $(OPENCODE_CONFIG_PATH) -> $(OPENCODE_DOTFILES_CONFIG)"; \
		else \
			echo "⚠️  config: $(OPENCODE_CONFIG_PATH) points to $$actual (expected $$expected)"; \
		fi; \
	elif [ -e "$(OPENCODE_CONFIG_PATH)" ]; then \
		echo "⚠️  config: $(OPENCODE_CONFIG_PATH) exists but is not a symlink"; \
	else \
		echo "⚠️  config: $(OPENCODE_CONFIG_PATH) is not configured"; \
	fi
	@if [ -f "$(OH_MY_OPENCODE_DOTFILES_CONFIG)" ]; then \
		if [ -L "$(OH_MY_OPENCODE_CONFIG_PATH)" ]; then \
			actual=$$(readlink -f "$(OH_MY_OPENCODE_CONFIG_PATH)" 2>/dev/null || readlink "$(OH_MY_OPENCODE_CONFIG_PATH)" 2>/dev/null || true); \
			expected=$$(readlink -f "$(OH_MY_OPENCODE_DOTFILES_CONFIG)" 2>/dev/null || true); \
			if [ -n "$$actual" ] && [ "$$actual" = "$$expected" ]; then \
				echo "✅ oh-my-config: $(OH_MY_OPENCODE_CONFIG_PATH) -> $(OH_MY_OPENCODE_DOTFILES_CONFIG)"; \
			else \
				echo "⚠️  oh-my-config: $(OH_MY_OPENCODE_CONFIG_PATH) points to $$actual (expected $$expected)"; \
			fi; \
		elif [ -e "$(OH_MY_OPENCODE_CONFIG_PATH)" ]; then \
			echo "⚠️  oh-my-config: $(OH_MY_OPENCODE_CONFIG_PATH) exists but is not a symlink"; \
		else \
			echo "⚠️  oh-my-config: $(OH_MY_OPENCODE_CONFIG_PATH) is not configured"; \
		fi; \
	fi
