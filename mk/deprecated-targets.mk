# 廃止予定ターゲット管理
# 旧ターゲット名→新ターゲット名のエイリアスマッピングを定義
# 短縮エイリアス (i, s, c, u, m, h, claudecode, s1-s5, ss, sg) は mk/shortcuts.mk で管理

# ==================== 廃止予定マップ ====================
# フォーマット: 旧名:新名:廃止開始日:削除予定日:ステータス
# ステータス: warning (警告フェーズ) / transition (移行期間) / removed (削除済み)
DEPRECATED_TARGETS :=

# ==================== 旧名→新名エイリアス ====================
# レガシーターゲット名から新しい命名規則に準拠したターゲット名へのマッピング
# 現在は後方互換性のためサイレントリダイレクトを提供
# 将来的に MAKE_DEPRECATION_WARN=1 で警告出力を有効化可能

# 例: 旧パッケージ管理ターゲット
# .PHONY: install-homebrew
# install-homebrew: install-packages-homebrew

# 例: 旧設定ターゲット
# .PHONY: setup-secrets
# setup-secrets: setup-config-secrets

# 注: 現在は具体的なエイリアスは未定義
# 廃止予定ターゲットが発生した際にここに追加する
