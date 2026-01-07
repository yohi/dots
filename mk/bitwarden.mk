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

# ============================================================
# Targets
# ============================================================
.PHONY: bw-status
bw-status: ## Bitwarden 連携の有効化状態を確認（基盤実装）
	@$(call bw_require_opt_in,$@); \
	echo "[INFO] Bitwarden integration is enabled."; \
	exit 0

.PHONY: bw-unlock
bw-unlock: ## Bitwarden セッションをアンロック（基盤実装、完全実装はタスク3.3）
	@$(call bw_require_opt_in,$@); \
	$(BW_REQUIRE_CLI); \
	echo "[INFO] Bitwarden CLI detected." >&2; \
	echo "[INFO] Full unlock implementation will be completed in task 3.3." >&2; \
	exit 0
