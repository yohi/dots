#!/bin/bash

# dotfiles Gnome Extensions Auto-Installer
# Author: y_ohi
# Description: Automatically install and configure Gnome Extensions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Log function
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running in GNOME
check_gnome() {
    if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "Unity" ]; then
        error "このスクリプトはGNOME/Unityデスクトップ環境でのみ動作します"
        exit 1
    fi
}

# Install gext if not available
install_gext() {
    if ! command -v gext &> /dev/null; then
        log "gnome-shell-extension-installer (gext) をインストール中..."
        
        # Try to install via package manager first
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y gnome-shell-extension-installer 2>/dev/null || {
                log "パッケージマネージャーからのインストールに失敗。PiPからインストールを試行中..."
                # Install via pip as fallback
                if command -v pip3 &> /dev/null; then
                    pip3 install --user gnome-shell-extension-installer
                elif command -v pip &> /dev/null; then
                    pip install --user gnome-shell-extension-installer
                else
                    error "pip が見つかりません。手動でgnome-shell-extension-installerをインストールしてください"
                    exit 1
                fi
            }
        else
            error "パッケージマネージャーが見つかりません"
            exit 1
        fi
    else
        success "gnome-shell-extension-installer (gext) は既にインストールされています"
    fi
}

# Install required packages
install_dependencies() {
    log "必要なパッケージをインストール中..."
    
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y \
            gnome-shell-extensions \
            gnome-shell-extension-manager \
            chrome-gnome-shell \
            curl \
            wget \
            unzip \
            dconf-cli \
            python3-pip
    else
        warning "aptパッケージマネージャーが見つかりません。手動で依存関係をインストールしてください"
    fi
}

# Function to install extension from extensions.gnome.org
install_extension_from_ego() {
    local extension_uuid="$1"
    local extension_name="$2"
    
    log "Extension をインストール中: $extension_name ($extension_uuid)"
    
    # Try using gext first
    if command -v gext &> /dev/null; then
        if gext install "$extension_uuid" --yes; then
            success "$extension_name のインストールが完了しました"
            return 0
        else
            warning "gext でのインストールに失敗しました。手動インストールを試行中..."
        fi
    fi
    
    # Fallback to manual installation
    local temp_dir=$(mktemp -d)
    local gnome_version=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1,2)
    
    # Try to get extension info from extensions.gnome.org API
    local api_url="https://extensions.gnome.org/extension-info/?uuid=${extension_uuid}&shell_version=${gnome_version}"
    
    if curl -s "$api_url" | grep -q "download_url"; then
        local download_url=$(curl -s "$api_url" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data['download_url'])
except:
    sys.exit(1)
")
        
        if [ -n "$download_url" ]; then
            log "$extension_name のダウンロード中..."
            if curl -L "https://extensions.gnome.org$download_url" -o "$temp_dir/extension.zip"; then
                local install_dir="$HOME/.local/share/gnome-shell/extensions/$extension_uuid"
                mkdir -p "$install_dir"
                
                if unzip -q "$temp_dir/extension.zip" -d "$install_dir"; then
                    success "$extension_name のインストールが完了しました"
                    rm -rf "$temp_dir"
                    return 0
                else
                    error "$extension_name の解凍に失敗しました"
                fi
            else
                error "$extension_name のダウンロードに失敗しました"
            fi
        fi
    fi
    
    rm -rf "$temp_dir"
    warning "$extension_name のインストールに失敗しました。手動でインストールしてください"
    return 1
}

# Install all extensions
install_extensions() {
    log "Gnome Extensions のインストールを開始します..."
    
    # Array of extensions (UUID, Name) - Only enabled extensions
    declare -a extensions=(
        "bluetooth-battery@michalw.github.com|Bluetooth Battery Indicator"
        "bluetooth-quick-connect@bjarosze.gmail.com|Bluetooth Quick Connect"
        "Move_Clock@rmy.pobox.com|Move Clock"
        "tweaks-system-menu@extensions.gnome-shell.fifi.org|Tweaks & Extensions in System Menu"
        "BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm|Bring Out Submenu Of Power Off/Logout Button"
        "PrivacyMenu@stuarthayhurst|Privacy Menu"
        "vertical-workspaces@G-dH.github.com|Vertical Workspaces"
        "monitor@astraext.github.io|Astra Monitor"
        "search-light@icedman.github.com|Search Light"
    )
    
    local success_count=0
    local total_count=${#extensions[@]}
    
    for extension_info in "${extensions[@]}"; do
        IFS='|' read -r extension_uuid extension_name <<< "$extension_info"
        
        # Check if extension is already installed
        if gnome-extensions list | grep -q "$extension_uuid"; then
            success "$extension_name は既にインストールされています"
            ((success_count++))
            continue
        fi
        
        # Try to install the extension
        if install_extension_from_ego "$extension_uuid" "$extension_name"; then
            ((success_count++))
        fi
        
        # Small delay to avoid overwhelming the server
        sleep 1
    done
    
    log "インストール完了: $success_count/$total_count 個の拡張機能"
}

# Enable extensions
enable_extensions() {
    log "Extensions を有効化中..."
    
    # List of extensions to enable
    local enabled_extensions=(
        "bluetooth-battery@michalw.github.com"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "Move_Clock@rmy.pobox.com"
        "tweaks-system-menu@extensions.gnome-shell.fifi.org"
        "BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm"
        "PrivacyMenu@stuarthayhurst"
        "vertical-workspaces@G-dH.github.com"
        "monitor@astraext.github.io"
        "search-light@icedman.github.com"
    )
    
    for extension_uuid in "${enabled_extensions[@]}"; do
        if gnome-extensions list | grep -q "$extension_uuid"; then
            if gnome-extensions enable "$extension_uuid" 2>/dev/null; then
                success "$extension_uuid を有効化しました"
            else
                warning "$extension_uuid の有効化に失敗しました"
            fi
        else
            warning "$extension_uuid がインストールされていません"
        fi
    done
}

# Apply extension settings
apply_settings() {
    log "Extension設定を適用中..."
    
    # Apply extension settings from dconf file
    local extensions_settings_file="$SCRIPT_DIR/extensions-settings.dconf"
    local shell_settings_file="$SCRIPT_DIR/shell-settings.dconf"
    
    if [ -f "$extensions_settings_file" ]; then
        log "Extensions設定を読み込み中..."
        dconf load /org/gnome/shell/extensions/ < "$extensions_settings_file"
        success "Extensions設定を適用しました"
    else
        warning "Extensions設定ファイルが見つかりません: $extensions_settings_file"
    fi
    
    if [ -f "$shell_settings_file" ]; then
        log "Shell設定を読み込み中..."
        dconf load /org/gnome/shell/ < "$shell_settings_file"
        success "Shell設定を適用しました"
    else
        warning "Shell設定ファイルが見つかりません: $shell_settings_file"
    fi
}

# Export current extensions and settings
export_current_setup() {
    log "現在のExtensions設定をエクスポート中..."
    
    # Export enabled extensions list
    gnome-extensions list --enabled > "$SCRIPT_DIR/enabled-extensions.txt"
    gnome-extensions list --disabled > "$SCRIPT_DIR/disabled-extensions.txt"
    
    # Export extension settings
    dconf dump /org/gnome/shell/extensions/ > "$SCRIPT_DIR/extensions-settings.dconf"
    dconf dump /org/gnome/shell/ > "$SCRIPT_DIR/shell-settings.dconf"
    
    success "設定のエクスポートが完了しました"
    log "エクスポートされたファイル:"
    log "  - enabled-extensions.txt"
    log "  - disabled-extensions.txt"
    log "  - extensions-settings.dconf"
    log "  - shell-settings.dconf"
}

# Restart GNOME Shell
restart_gnome_shell() {
    log "GNOME Shellを再起動しています..."
    
    if [ "$XDG_SESSION_TYPE" = "x11" ]; then
        # X11 session
        killall -HUP gnome-shell
        success "GNOME Shell を再起動しました (X11)"
    else
        # Wayland session
        warning "Waylandセッションではシェルの再起動ができません"
        warning "ログアウト/ログインまたはシステム再起動を推奨します"
    fi
}

# Main function
main() {
    echo "🚀 Gnome Extensions 自動セットアップ"
    echo "=================================="
    
    # Parse command line arguments
    case "${1:-install}" in
        "install")
            check_gnome
            install_dependencies
            install_gext
            install_extensions
            enable_extensions
            apply_settings
            restart_gnome_shell
            ;;
        "export")
            check_gnome
            export_current_setup
            ;;
        "apply-settings")
            check_gnome
            apply_settings
            restart_gnome_shell
            ;;
        "enable")
            check_gnome
            enable_extensions
            ;;
        *)
            echo "使用方法: $0 [install|export|apply-settings|enable]"
            echo ""
            echo "コマンド:"
            echo "  install        - Extensions をインストールし設定を適用"
            echo "  export         - 現在の設定をエクスポート"
            echo "  apply-settings - 設定のみを適用"
            echo "  enable         - Extensions を有効化"
            exit 1
            ;;
    esac
    
    echo ""
    success "🎉 完了しました！"
    echo ""
    echo "💡 注意："
    echo "  - 一部のExtensionsは手動での設定が必要な場合があります"
    echo "  - Extension Manager (com.mattjakeman.ExtensionManager) で設定を確認してください"
    echo "  - 変更を完全に反映するにはログアウト/ログインを推奨します"
}

# Run main function
main "$@" 