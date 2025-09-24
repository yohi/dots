# ===================================================================
# Zsh Configuration File
# ===================================================================
# このファイルで zsh 関数読み込みのパスや設定をカスタマイズできます

# DOTS_ROOT のカスタム設定
# 環境変数で指定されていない場合、この値が使用されます
#CUSTOM_DOTS_ROOT="$HOME/dots"

# 関数読み込みの設定
FUNCTIONS_SUBDIR="zsh/functions"           # 関数ディレクトリのサブパス
FUNCTIONS_DEBUG=${ZSH_FUNCTIONS_DEBUG:-false}  # デバッグモード

# 読み込み対象ファイルパターン
FUNCTIONS_PATTERN="**/*.zsh"               # 読み込み対象ファイル

# スキップするファイルパターン
FUNCTIONS_SKIP_PATTERNS=(
    "*.broken"
    "*.disabled"
    "*.tmp"
    "*.backup"
    "*~"
)

# 代替検索ディレクトリ（優先度順）
CANDIDATE_DIRS=(
    "$HOME/dots"
    "$HOME/.dots"
    "$HOME/dotfiles"
    "$HOME/.dotfiles"
    "$HOME/.config/dots"
    "/home/$USER/dots"
)
