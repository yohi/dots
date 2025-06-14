#!/bin/bash

# dotfiles installer script
# Usage: curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash

set -e

# 色付きメッセージの定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 設定変数
REPO_URL="https://github.com/yohi/dots.git"
DOTFILES_DIR="$HOME/dots"
BRANCH="main"

# 引数の処理
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
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --branch BRANCH    指定したブランチをクローン (default: main)"
            echo "  --dir DIR          クローン先ディレクトリ (default: ~/dots)"
            echo "  --help, -h         このヘルプを表示"
            exit 0
            ;;
        *)
            log_error "不明なオプション: $1"
            exit 1
            ;;
    esac
done

# 前提条件のチェックとインストール
check_prerequisites() {
    log_info "前提条件をチェック中..."
    
    local packages_to_install=()
    
    # gitの存在確認
    if ! command -v git &> /dev/null; then
        log_warn "gitがインストールされていません"
        packages_to_install+=("git")
    else
        log_success "git は既にインストールされています"
    fi
    
    # makeの存在確認
    if ! command -v make &> /dev/null; then
        log_warn "makeがインストールされていません"
        packages_to_install+=("build-essential")
    else
        log_success "make は既にインストールされています"
    fi
    
    # 必要なパッケージをインストール
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        log_info "必要なパッケージをインストール中: ${packages_to_install[*]}"
        
        # パッケージリストを更新
        log_info "パッケージリストを更新中..."
        sudo apt update
        
        # パッケージをインストール
        log_info "パッケージをインストール中..."
        sudo apt install -y "${packages_to_install[@]}"
        
        log_success "必要なパッケージのインストールが完了しました"
        
        # インストール後の確認
        if ! command -v git &> /dev/null; then
            log_error "gitのインストールに失敗しました"
            exit 1
        fi
        
        if ! command -v make &> /dev/null; then
            log_error "makeのインストールに失敗しました"
            exit 1
        fi
    fi
    
    log_success "前提条件のチェック完了"
}

# リポジトリのクローン
clone_repository() {
    log_info "dotfilesリポジトリをクローン中..."
    
    if [ -d "$DOTFILES_DIR" ]; then
        log_warn "ディレクトリ $DOTFILES_DIR が既に存在します"
        read -p "既存のディレクトリを削除してクローンしますか? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$DOTFILES_DIR"
            log_info "既存のディレクトリを削除しました"
        else
            log_info "既存のディレクトリに移動してpullします"
            cd "$DOTFILES_DIR"
            git pull origin "$BRANCH"
            log_success "リポジトリを更新しました"
            return 0
        fi
    fi
    
    git clone -b "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
    log_success "リポジトリのクローン完了: $DOTFILES_DIR"
}

# dotfilesのセットアップ
setup_dotfiles() {
    log_info "dotfilesのセットアップを開始..."
    
    cd "$DOTFILES_DIR"
    
    # Makefileのヘルプを表示
    log_info "利用可能なセットアップオプション:"
    make help
    
    echo ""
    log_info "推奨セットアップ手順:"
    log_info "1. システムレベルの設定: make system-setup"
    log_info "2. Homebrew インストール: make install-homebrew"
    log_info "3. 全体セットアップ: make setup-all"
    
    echo ""
    read -p "自動で推奨セットアップを実行しますか? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "推奨セットアップを実行中..."
        
        # システム設定
        log_info "システムレベルの設定を実行中..."
        make system-setup
        
        # Homebrew インストール
        log_info "Homebrew をインストール中..."
        make install-homebrew
        
        # 全体セットアップ
        log_info "全体セットアップを実行中..."
        make setup-all
        
        log_success "推奨セットアップが完了しました！"
    else
        log_info "手動でセットアップを行ってください"
        log_info "ディレクトリ: $DOTFILES_DIR"
        log_info "使用可能なコマンド: make help"
    fi
}

# メイン処理
main() {
    log_info "dotfiles インストーラーを開始します"
    log_info "リポジトリ: $REPO_URL"
    log_info "ブランチ: $BRANCH"
    log_info "インストール先: $DOTFILES_DIR"
    echo ""
    
    check_prerequisites
    clone_repository
    setup_dotfiles
    
    log_success "dotfiles のインストールが完了しました！"
    log_info "詳細なセットアップオプションについては、以下を参照してください:"
    log_info "cd $DOTFILES_DIR && make help"
}

# スクリプト実行
main "$@" 