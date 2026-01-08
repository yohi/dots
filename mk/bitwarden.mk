# Bitwarden integration (opt-in)

# ============================================================
# Opt-in gate
# ============================================================
# WITH_BW=1 の場合のみ Bitwarden 連携を有効化する。
# 未設定または WITH_BW=0 の場合は警告のみで終了する。

BW_WARN_MESSAGE := [WARN] Bitwarden integration is disabled.
BW_WARN_SKIP :=        Skipping Bitwarden operations.

BW_ERROR_MISSING := [ERROR] Bitwarden CLI (bw) is not installed.
BW_ERROR_HINT1 :=         Install with: brew install bitwarden-cli
BW_ERROR_HINT2 :=         Or run: make install-packages-apps
BW_ERROR_JQ := [ERROR] jq is required for Bitwarden integration.
BW_ERROR_JQ_HINT1 :=         Install with: brew install jq
BW_ERROR_JQ_HINT2 :=         Or: apt install jq
BW_ERROR_UNLOCK_FAILED := [ERROR] Failed to unlock Bitwarden vault.
BW_ERROR_UNLOCK_HINT1 :=         Check your master password and try again.
BW_ERROR_SESSION_EXPIRED := [ERROR] Bitwarden session has expired.
BW_ERROR_SESSION_INVALID := [ERROR] Invalid Bitwarden session token.
BW_ERROR_SESSION_INVALID_HINT :=         Your session may have been invalidated.
BW_ERROR_SESSION_HINT1 :=         Run: eval $$(make bw-unlock WITH_BW=1)
BW_ERROR_SESSION_HINT2 :=         Or: export BW_SESSION=$$(bw unlock --raw)
BW_ERROR_NOT_LOGGED_IN := [ERROR] Bitwarden CLI is not logged in.
BW_ERROR_NOT_LOGGED_IN_HINT1 :=         Run: bw login
BW_ERROR_NOT_LOGGED_IN_HINT2 :=         Or set BW_CLIENTID and BW_CLIENTSECRET for API key login.
BW_ERROR_VAULT_LOCKED := [ERROR] Bitwarden vault is locked.
BW_ERROR_VAULT_LOCKED_HINT1 :=         Run: eval $$(make bw-unlock WITH_BW=1)
BW_ERROR_VAULT_LOCKED_HINT2 :=         Or: export BW_SESSION=$$(bw unlock --raw)
BW_ERROR_SECRET_NOT_FOUND := [ERROR] Secret not found:
BW_ERROR_SECRET_NOT_FOUND_HINT1 :=         Verify the item exists in your Bitwarden vault.
BW_ERROR_SECRET_NOT_FOUND_HINT2 :=         Search with: bw list items --search
BW_ERROR_NETWORK := [ERROR] Failed to connect to Bitwarden server.
BW_ERROR_NETWORK_HINT1 :=         Check your network connection and try again.
BW_ERROR_NETWORK_HINT2 :=         If using self-hosted, verify BW_SERVER is set correctly.

# Use a single-line shell block so "exit 0" stops the recipe.
bw_require_opt_in = if [ "$${WITH_BW:-0}" != "1" ]; then \
	echo "$(BW_WARN_MESSAGE)" >&2; \
	echo "       To enable, run with: make $(1) WITH_BW=1" >&2; \
	echo "$(BW_WARN_SKIP)" >&2; \
	exit 0; \
fi

BW_REQUIRE_CLI = if ! command -v bw >/dev/null 2>&1; then \
	echo "$(BW_ERROR_MISSING)" >&2; \
	echo "$(BW_ERROR_HINT1)" >&2; \
	echo "$(BW_ERROR_HINT2)" >&2; \
	exit 1; \
fi

BW_REQUIRE_JQ = if ! command -v jq >/dev/null 2>&1; then \
	echo "$(BW_ERROR_JQ)" >&2; \
	echo "$(BW_ERROR_JQ_HINT1)" >&2; \
	echo "$(BW_ERROR_JQ_HINT2)" >&2; \
	exit 1; \
fi

bw_check_status = $(call _bw_check_status_impl)

define _bw_check_status_impl
	if ! command -v bw >/dev/null 2>&1; then \
		echo "not_installed"; \
		exit 0; \
	fi; \
	if ! command -v jq >/dev/null 2>&1; then \
		echo "jq_missing"; \
		exit 0; \
	fi; \
	status=$$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
	case "$$status" in \
		unlocked|locked|unauthenticated) echo "$$status" ;; \
		*) echo "error" ;; \
	esac
endef

bw_get_item = $(BW_REQUIRE_CLI); \
	$(BW_REQUIRE_JQ); \
	if [ -z "$$BW_SESSION" ]; then \
		echo "$(BW_ERROR_VAULT_LOCKED)" >&2; \
		echo "$(BW_ERROR_VAULT_LOCKED_HINT1)" >&2; \
		echo "$(BW_ERROR_VAULT_LOCKED_HINT2)" >&2; \
		exit 1; \
	fi; \
	status=$$(BW_SESSION="$$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
	if [ "$$status" = "unauthenticated" ]; then \
		echo "$(BW_ERROR_NOT_LOGGED_IN)" >&2; \
		echo "$(BW_ERROR_NOT_LOGGED_IN_HINT1)" >&2; \
		echo "$(BW_ERROR_NOT_LOGGED_IN_HINT2)" >&2; \
		exit 1; \
	fi; \
	if [ "$$status" = "locked" ]; then \
		echo "$(BW_ERROR_VAULT_LOCKED)" >&2; \
		echo "$(BW_ERROR_VAULT_LOCKED_HINT1)" >&2; \
		echo "$(BW_ERROR_VAULT_LOCKED_HINT2)" >&2; \
		exit 1; \
	fi; \
	if [ "$$status" != "unlocked" ]; then \
		echo "$(BW_ERROR_NETWORK)" >&2; \
		echo "$(BW_ERROR_NETWORK_HINT1)" >&2; \
		echo "$(BW_ERROR_NETWORK_HINT2)" >&2; \
		exit 1; \
	fi; \
	item=$$(BW_SESSION="$$BW_SESSION" bw get item "$(1)" 2>/dev/null || true); \
	if [ -z "$$item" ]; then \
		echo "$(BW_ERROR_SECRET_NOT_FOUND) $(1)" >&2; \
		echo "$(BW_ERROR_SECRET_NOT_FOUND_HINT1)" >&2; \
		echo "$(BW_ERROR_SECRET_NOT_FOUND_HINT2) \"$(1)\"" >&2; \
		exit 1; \
	fi; \
	secret=$$(printf '%s\n' "$$item" | jq -r '.login.password // .notes // empty'); \
	if [ -z "$$secret" ]; then \
		echo "$(BW_ERROR_SECRET_NOT_FOUND) $(1)" >&2; \
		echo "$(BW_ERROR_SECRET_NOT_FOUND_HINT1)" >&2; \
		echo "$(BW_ERROR_SECRET_NOT_FOUND_HINT2) \"$(1)\"" >&2; \
		exit 1; \
	fi; \
	printf '%s\n' "$$secret"

# ============================================================
# Targets
# ============================================================
.PHONY: bw-status
bw-status: ## Bitwarden CLI の状態を表示
	@$(call bw_require_opt_in,$@); \
	echo "=== Bitwarden CLI Status ==="; \
	if ! command -v bw >/dev/null 2>&1; then \
		echo "Status: NOT INSTALLED"; \
		echo "Install with: brew install bitwarden-cli"; \
		echo ""; \
		echo "WITH_BW flag: $${WITH_BW:-not set}"; \
		echo "BW_SESSION: $$([ -n \"$$BW_SESSION\" ] && echo 'set (hidden)' || echo 'not set')"; \
		exit 1; \
	fi; \
	if ! command -v jq >/dev/null 2>&1; then \
		status_json=$$(bw status 2>/dev/null || true); \
		status=$${status_json#*\"status\":\"}; \
		status=$${status%%\"*}; \
		if [ -n "$$status" ] && [ "$$status" != "$$status_json" ]; then \
			echo "Vault Status: $$status"; \
		fi; \
		echo "$(BW_ERROR_JQ)" >&2; \
		echo "$(BW_ERROR_JQ_HINT1)" >&2; \
		echo "$(BW_ERROR_JQ_HINT2)" >&2; \
		exit 1; \
	fi; \
	echo "CLI Version: $$(bw --version)"; \
	status=$$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
	if [ -z "$$status" ]; then status="error"; fi; \
	echo "Vault Status: $$status"; \
	exit_code=0; \
	if [ "$$status" = "unlocked" ]; then \
		email=$$(bw status 2>/dev/null | jq -r '.userEmail' 2>/dev/null); \
		echo "Logged in as: $$email"; \
	else \
		exit_code=1; \
	fi; \
	echo ""; \
	echo "WITH_BW flag: $${WITH_BW:-not set}"; \
	echo "BW_SESSION: $$([ -n \"$$BW_SESSION\" ] && echo 'set (hidden)' || echo 'not set')"; \
	exit $$exit_code

.PHONY: bw-unlock
bw-unlock: ## Bitwarden セッションをアンロックして BW_SESSION を出力
	@$(call bw_require_opt_in,$@); \
	$(BW_REQUIRE_CLI); \
	$(BW_REQUIRE_JQ); \
	if [ -n "$$BW_SESSION" ] && [ "$${FORCE:-0}" != "1" ]; then \
		status=$$(BW_SESSION="$$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
		case "$$status" in \
			unlocked) echo "export BW_SESSION=\"$$BW_SESSION\""; exit 0 ;; \
			locked) \
				echo "$(BW_ERROR_SESSION_EXPIRED)" >&2; \
				echo "$(BW_ERROR_SESSION_HINT1)" >&2; \
				echo "$(BW_ERROR_SESSION_HINT2)" >&2; \
				exit 1 ;; \
			unauthenticated|error) \
				echo "$(BW_ERROR_SESSION_INVALID)" >&2; \
				echo "$(BW_ERROR_SESSION_INVALID_HINT)" >&2; \
				echo "$(BW_ERROR_SESSION_HINT1)" >&2; \
				exit 1 ;; \
		esac; \
	fi; \
	status=$$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
	if [ "$$status" = "unauthenticated" ]; then \
		echo "[ERROR] Bitwarden CLI is not logged in." >&2; \
		echo "        Run: bw login" >&2; \
		echo "        Or set BW_CLIENTID and BW_CLIENTSECRET for API key login." >&2; \
		exit 1; \
	fi; \
	if [ -n "$$BW_PASSWORD" ]; then \
		session=$$(printf '%s' "$$BW_PASSWORD" | bw unlock --raw 2>/dev/null); \
	else \
		session=$$(bw unlock --raw 2>/dev/null); \
	fi; \
	if [ -z "$$session" ]; then \
	echo "$(BW_ERROR_UNLOCK_FAILED)" >&2; \
	echo "$(BW_ERROR_UNLOCK_HINT1)" >&2; \
	exit 1; \
	fi; \
	echo "export BW_SESSION=\"$$session\""

.PHONY: bw-get-item-%
bw-get-item-%: ## 指定アイテムのシークレットを取得
	@$(call bw_require_opt_in,$@); \
	$(call bw_get_item,$*)

.PHONY: setup-config-secrets
setup-config-secrets: ## Bitwarden からシークレットを取得して保存
	@$(call bw_require_opt_in,$@); \
	set -euo pipefail; \
	if [ -z "$$BW_SECRET_ITEM" ]; then \
		echo "[ERROR] BW_SECRET_ITEM is required." >&2; \
		exit 1; \
	fi; \
	if [ -z "$$BW_SECRET_KEY" ]; then \
		echo "[ERROR] BW_SECRET_KEY is required." >&2; \
		exit 1; \
	fi; \
	if [ -z "$$BW_SECRETS_FILE" ]; then \
		echo "[ERROR] BW_SECRETS_FILE is required." >&2; \
		exit 1; \
	fi; \
	secret="$$( $(call bw_get_item,$$BW_SECRET_ITEM) )"; \
	secrets_file="$$BW_SECRETS_FILE"; \
	key="$$BW_SECRET_KEY"; \
	tmp_file="$$secrets_file.tmp"; \
	mkdir -p "$$(dirname "$$secrets_file")"; \
	if [ -f "$$secrets_file" ]; then \
		grep -v "^$$key=" "$$secrets_file" > "$$tmp_file"; \
	else \
		: > "$$tmp_file"; \
	fi; \
	printf '%s=%s\n' "$$key" "$$secret" >> "$$tmp_file"; \
	chmod 600 "$$tmp_file"; \
	mv "$$tmp_file" "$$secrets_file"; \
	echo "[OK] Stored secret for $$key in $$secrets_file."
