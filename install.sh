#!/bin/bash

# dotfiles installer script
# Usage: curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash

set -euo pipefail

# 色付きメッセージの定義
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# ログ用関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

log_progress() {
    echo -e "${CYAN}[PROGRESS]${NC} $1"
}

# 設定変数
readonly REPO_URL="https://github.com/yohi/dots.git"
readonly DEFAULT_DOTFILES_DIR="$HOME/dots"
readonly DEFAULT_BRANCH="main"
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/tmp/dotfiles-install-$(date +%Y%m%d-%H%M%S).log"

# 変数の初期化
DOTFILES_DIR="$DEFAULT_DOTFILES_DIR"
BRANCH="$DEFAULT_BRANCH"
FORCE_INSTALL=false
SKIP_CONFIRMATION=false

# ヘルプメッセージ
show_help() {
    cat << EOF
🚀 Ubuntu開発環境セットアップ dotfiles インストーラー

使用方法:
  $SCRIPT_NAME [OPTIONS]

オプション:
  --branch BRANCH       指定したブランチをクローン (default: main)
  --dir DIR            クローン先ディレクトリ (default: ~/dots)
  --force              既存のディレクトリを強制的に上書き
  --yes                確認プロンプトをスキップ
  --help, -h           このヘルプを表示
  --version, -v        バージョン情報を表示

例:
  # 基本インストール
  $SCRIPT_NAME
  
  # 特定のブランチをインストール
  $SCRIPT_NAME --branch develop
  
  # カスタムディレクトリにインストール
  $SCRIPT_NAME --dir ~/my-dotfiles
  
  # 強制インストール（確認なし）
  $SCRIPT_NAME --force --yes

EOF
}

# バージョン情報
show_version() {
    echo "Ubuntu開発環境セットアップ dotfiles v2.0.0"
    echo "https://github.com/yohi/dots"
}

# 引数の処理
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --dir)
                DOTFILES_DIR="$2"
                shift 2
                ;;
            --force)
                FORCE_INSTALL=true
                shift
                ;;
            --yes|-y)
                SKIP_CONFIRMATION=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            *)
                log_error "不明なオプション: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# ロギング設定
setup_logging() {
    exec 3>&1 4>&2
    if [[ -w "$(dirname "$LOG_FILE")" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2> >(tee -a "$LOG_FILE" >&2)
        log_info "ログファイル: $LOG_FILE"
    else
        log_warn "ログファイルを作成できません: $LOG_FILE"
    fi
}

# システム情報の取得
get_system_info() {
    log_step "システム情報を取得中..."
    
    local os_name
    local os_version
    local arch
    
    os_name=$(lsb_release -si 2>/dev/null || echo "Unknown")
    os_version=$(lsb_release -sr 2>/dev/null || echo "Unknown")
    arch=$(uname -m)
    
    log_info "OS: $os_name $os_version"
    log_info "アーキテクチャ: $arch"
    log_info "シェル: $SHELL"
    log_info "ユーザー: $USER"
    
    # Ubuntu以外の場合は警告
    if [[ "$os_name" != "Ubuntu" ]]; then
        log_warn "このスクリプトはUbuntu用に設計されています"
        log_warn "他のディストリビューションでは正常に動作しない可能性があります"
    fi
}

# 前提条件のチェックとインストール
check_prerequisites() {
    log_step "前提条件をチェック中..."
    
    local packages_to_install=()
    local missing_commands=()
    
    # 必須コマンドの確認
    local required_commands=("curl" "wget" "git" "make")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
            case $cmd in
                curl|wget)
                    packages_to_install+=("$cmd")
                    ;;
                git)
                    packages_to_install+=("git")
                    ;;
                make)
                    packages_to_install+=("build-essential")
                    ;;
            esac
        else
            log_success "$cmd は既にインストールされています"
        fi
    done
    
    # 必要なパッケージをインストール
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        log_info "必要なパッケージをインストール中: ${packages_to_install[*]}"
        
        # パッケージリストを更新
        log_progress "パッケージリストを更新中..."
        if ! sudo apt update; then
            log_error "パッケージリストの更新に失敗しました"
            exit 1
        fi
        
        # パッケージをインストール
        log_progress "パッケージをインストール中..."
        if ! sudo apt install -y "${packages_to_install[@]}"; then
            log_error "パッケージのインストールに失敗しました"
            exit 1
        fi
        
        log_success "必要なパッケージのインストールが完了しました"
        
        # インストール後の確認
        for cmd in "${missing_commands[@]}"; do
            if ! command -v "$cmd" &> /dev/null; then
                log_error "$cmd のインストールに失敗しました"
                exit 1
            fi
        done
    fi
    
    log_success "前提条件のチェック完了"
}

# 既存ディレクトリの処理
handle_existing_directory() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        return 0
    fi
    
    log_warn "ディレクトリ '$DOTFILES_DIR' が既に存在します"
    
    if [[ "$FORCE_INSTALL" == true ]]; then
        log_info "強制インストールが指定されているため、既存のディレクトリを削除します"
        rm -rf "$DOTFILES_DIR"
        return 0
    fi
    
    if [[ "$SKIP_CONFIRMATION" == true ]]; then
        log_info "既存のディレクトリに移動してpullします"
        return 1
    fi
    
    echo
    log_warn "既存のディレクトリをどう処理しますか？"
    echo "  1) 削除してクローンし直す"
    echo "  2) 既存のディレクトリでgit pullする"
    echo "  3) 別のディレクトリ名を指定する"
    echo "  4) 中止する"
    echo
    
    local choice
    read -p "選択してください (1-4): " choice
    
    case $choice in
        1)
            log_info "既存のディレクトリを削除しています..."
            rm -rf "$DOTFILES_DIR"
            return 0
            ;;
        2)
            log_info "既存のディレクトリでgit pullを実行します"
            return 1
            ;;
        3)
            read -p "新しいディレクトリ名を入力してください: " DOTFILES_DIR
            DOTFILES_DIR="${DOTFILES_DIR/#\~/$HOME}"
            handle_existing_directory
            return $?
            ;;
        4)
            log_info "インストールを中止しました"
            exit 0
            ;;
        *)
            log_error "無効な選択です"
            handle_existing_directory
            return $?
            ;;
    esac
}

# リポジトリのクローン
clone_repository() {
    log_step "dotfilesリポジトリを取得中..."
    
    if handle_existing_directory; then
        # 新規クローン
        log_progress "リポジトリをクローンしています..."
        log_info "URL: $REPO_URL"
        log_info "ブランチ: $BRANCH"
        log_info "ディレクトリ: $DOTFILES_DIR"
        
        if ! git clone -b "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"; then
            log_error "リポジトリのクローンに失敗しました"
            exit 1
        fi
        
        log_success "リポジトリのクローン完了"
    else
        # 既存リポジトリの更新
        log_progress "既存のリポジトリを更新中..."
        
        if ! cd "$DOTFILES_DIR"; then
            log_error "ディレクトリに移動できません: $DOTFILES_DIR"
            exit 1
        fi
        
        # リモートの確認
        local current_remote
        current_remote=$(git remote get-url origin 2>/dev/null || echo "")
        
        if [[ "$current_remote" != "$REPO_URL" ]]; then
            log_warn "リモートURLが異なります"
            log_warn "現在: $current_remote"
            log_warn "期待: $REPO_URL"
        fi
        
        # ブランチの確認と切り替え
        local current_branch
        current_branch=$(git branch --show-current 2>/dev/null || echo "")
        
        if [[ "$current_branch" != "$BRANCH" ]]; then
            log_info "ブランチを '$BRANCH' に切り替えています..."
            git fetch origin "$BRANCH"
            git checkout "$BRANCH"
        fi
        
        # プル実行
        if ! git pull origin "$BRANCH"; then
            log_error "git pullに失敗しました"
            exit 1
        fi
        
        log_success "リポジトリの更新完了"
    fi
}

# dotfilesのセットアップ
setup_dotfiles() {
    log_step "dotfilesのセットアップを開始..."
    
    if ! cd "$DOTFILES_DIR"; then
        log_error "ディレクトリに移動できません: $DOTFILES_DIR"
        exit 1
    fi
    
    # Makefileの存在確認
    if [[ ! -f "Makefile" ]]; then
        log_error "Makefileが見つかりません"
        exit 1
    fi
    
    # 利用可能なターゲットを表示
    log_info "利用可能なセットアップオプション:"
    make help
    
    echo ""
    log_info "📦 推奨セットアップ手順:"
    log_info "  1. システムレベルの設定: make system-setup"
    log_info "  2. Homebrew インストール: make install-homebrew" 
    log_info "  3. 全体セットアップ: make setup-all"
    
    if [[ "$SKIP_CONFIRMATION" == true ]]; then
        log_info "自動モードが指定されているため、推奨セットアップを実行します"
        run_recommended_setup
        return
    fi
    
    echo ""
    local choice
    read -p "自動で推奨セットアップを実行しますか? (y/N): " choice
    
    case $choice in
        [Yy]*)
            run_recommended_setup
            ;;
        *)
            log_info "手動でセットアップを行ってください"
            log_info "ディレクトリ: $DOTFILES_DIR"
            log_info "使用可能なコマンド: make help"
            ;;
    esac
}

# 推奨セットアップの実行
run_recommended_setup() {
    log_step "推奨セットアップを実行中..."
    
    local steps=(
        "system-setup:システムレベルの設定"
        "install-homebrew:Homebrew インストール"
        "setup-all:全体セットアップ"
    )
    
    for step_info in "${steps[@]}"; do
        local step="${step_info%%:*}"
        local description="${step_info##*:}"
        
        log_progress "$description を実行中..."
        
        if ! timeout 1800 make "$step"; then  # 30分のタイムアウト
            log_error "$description が失敗しました"
            log_error "手動で以下のコマンドを実行してください: make $step"
            return 1
        fi
        
        log_success "$description が完了しました"
    done
    
    log_success "推奨セットアップがすべて完了しました！"
}

# クリーンアップ
cleanup() {
    if [[ -f "$LOG_FILE" ]]; then
        log_info "ログファイルを保存しました: $LOG_FILE"
    fi
    
    # ファイルディスクリプタを復元
    exec 1>&3 2>&4
    exec 3>&- 4>&-
}

# メイン処理
main() {
    # 引数の解析
    parse_arguments "$@"
    
    # ロギング設定
    setup_logging
    
    # クリーンアップの設定
    trap cleanup EXIT
    
    # ヘッダー表示
    echo "======================================================"
    echo "🚀 Ubuntu開発環境セットアップ dotfiles インストーラー"
    echo "======================================================"
    echo ""
    
    log_info "開始時刻: $(date)"
    log_info "リポジトリ: $REPO_URL"
    log_info "ブランチ: $BRANCH"
    log_info "インストール先: $DOTFILES_DIR"
    echo ""
    
    # 実行手順
    get_system_info
    check_prerequisites
    clone_repository
    setup_dotfiles
    
    echo ""
    echo "======================================================"
    log_success "🎉 dotfiles のインストールが完了しました！"
    echo "======================================================"
    echo ""
    log_info "📁 dotfiles ディレクトリ: $DOTFILES_DIR"
    log_info "📖 詳細なセットアップオプション: cd $DOTFILES_DIR && make help"
    log_info "🔧 手動設定が必要な場合は、READMEを参照してください"
    echo ""
    log_info "完了時刻: $(date)"
}

# スクリプト実行
main "$@" 