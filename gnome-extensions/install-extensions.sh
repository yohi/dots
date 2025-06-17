#!/bin/bash

# dotfiles Gnome Extensions Auto-Installer
# Author: y_ohi
# Description: Automatically install and configure Gnome Extensions

set -euo pipefail

# Check for required dependencies
check_dependencies() {
    local dependencies=("curl" "unzip" "python3" "gnome-shell" "gnome-extensions" "dconf" "jq")
    local missing_deps=()

    log "必要な依存関係をチェック中..."

    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "以下の必要なコマンドが見つかりません:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        error "必要な依存関係をインストールしてからスクリプトを再実行してください"
        exit 1
    fi

    success "すべての必要な依存関係が利用可能です"
}

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

# Install gext if not available (deprecated - using API method instead)
install_gext() {
    warning "gnome-shell-extension-installer は非推奨です。代わりにAPI経由でインストールします。"
    return 0
}

# Install required packages
install_dependencies() {
    log "必要なパッケージをインストール中..."

    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y \
            gnome-shell-extensions \
            gnome-shell-extension-manager \
            gnome-browser-connector \
            curl \
            wget \
            unzip \
            dconf-cli \
            jq \
            python3 \
            libglib2.0-dev
    else
        warning "aptパッケージマネージャーが見つかりません。手動で依存関係をインストールしてください"
    fi
}

# Compile schemas for extension
compile_extension_schemas() {
    local extension_uuid="$1"
    local extension_dir="$HOME/.local/share/gnome-shell/extensions/$extension_uuid"
    local schemas_dir="$extension_dir/schemas"

    if [ -d "$schemas_dir" ]; then
        log "$extension_uuid のスキーマをコンパイル中..."
        if ls "$schemas_dir"/*.gschema.xml 1> /dev/null 2>&1; then
            if glib-compile-schemas "$schemas_dir" 2>/dev/null; then
                success "$extension_uuid のスキーマをコンパイルしました"
                return 0
            else
                warning "$extension_uuid のスキーマコンパイルに失敗しました"
                return 1
            fi
        fi
    fi
    return 0
}

# Function to install extension from extensions.gnome.org
install_extension_from_ego() {
    local extension_uuid="$1"
    local extension_name="$2"

        log "Extension をインストール中: $extension_name ($extension_uuid)"

    # Check if already installed
    if [ -d "$HOME/.local/share/gnome-shell/extensions/$extension_uuid" ]; then
        log "$extension_name は既にインストールされています"
        compile_extension_schemas "$extension_uuid"
        return 0
    fi

    # Using API method directly (gext is deprecated)
    log "API経由で直接インストール中..."

    # Fallback to manual installation
    local temp_dir=$(mktemp -d)
    local gnome_version=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1,2)

    # Try to get extension info from extensions.gnome.org API
    local api_url="https://extensions.gnome.org/extension-info/?uuid=${extension_uuid}&shell_version=${gnome_version}"

    if curl -s "$api_url" | grep -q "download_url"; then
        local download_url=""
        if command -v jq &> /dev/null; then
            download_url=$(curl -s "$api_url" | jq -r '.download_url // empty' 2>/dev/null || echo "")
        else
            download_url=$(curl -s "$api_url" | python3 -c "import json,sys; print(json.load(sys.stdin).get('download_url','') if sys.stdin.readable() else '')" 2>/dev/null || echo "")
        fi

        if [ -n "$download_url" ]; then
            log "$extension_name のダウンロード中..."
            if curl -L "https://extensions.gnome.org$download_url" -o "$temp_dir/extension.zip"; then
                local install_dir="$HOME/.local/share/gnome-shell/extensions/$extension_uuid"
                mkdir -p "$install_dir"

                if unzip -q "$temp_dir/extension.zip" -d "$install_dir"; then
                    success "$extension_name のインストールが完了しました"
                    # Compile schemas if they exist
                    compile_extension_schemas "$extension_uuid"
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

    # Wait a moment for extensions to be fully installed
    sleep 2

    for extension_uuid in "${enabled_extensions[@]}"; do
        if gnome-extensions list | grep -q "$extension_uuid"; then
            # Compile schemas before enabling
            compile_extension_schemas "$extension_uuid"

            # Try to enable the extension multiple times if needed
            local retry_count=0
            local max_retries=3

            while [ $retry_count -lt $max_retries ]; do
                if gnome-extensions enable "$extension_uuid" 2>/dev/null; then
                    success "$extension_uuid を有効化しました"
                    break
                else
                    ((retry_count++))
                    if [ $retry_count -lt $max_retries ]; then
                        warning "$extension_uuid の有効化に失敗しました (試行 $retry_count/$max_retries)。再試行中..."
                        sleep 1
                    else
                        warning "$extension_uuid の有効化に失敗しました (最大試行回数に達しました)"
                    fi
                fi
            done
        else
            warning "$extension_uuid がインストールされていません"
        fi
    done

    # Force enable critical extensions
    log "重要な拡張機能の強制有効化を実行中..."
    gnome-extensions enable "monitor@astraext.github.io" 2>/dev/null || warning "Astra Monitor の強制有効化に失敗"
    gnome-extensions enable "search-light@icedman.github.com" 2>/dev/null || warning "Search Light の強制有効化に失敗"
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

# Verify installation
verify_installation() {
    log "インストールの検証中..."

    # Critical extensions that must be enabled
    local critical_extensions=(
        "monitor@astraext.github.io"
        "search-light@icedman.github.com"
        "bluetooth-battery@michalw.github.com"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "tweaks-system-menu@extensions.gnome-shell.fifi.org"
        "BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm"
        "PrivacyMenu@stuarthayhurst"
    )

    local enabled_list
    enabled_list=$(gnome-extensions list --enabled)
    local missing_extensions=()

    for extension_uuid in "${critical_extensions[@]}"; do
        if echo "$enabled_list" | grep -q "$extension_uuid"; then
            success "✓ $extension_uuid は有効化されています"
        else
            warning "✗ $extension_uuid が有効化されていません"
            missing_extensions+=("$extension_uuid")
        fi
    done

    # Try to enable missing extensions one more time
    if [ ${#missing_extensions[@]} -gt 0 ]; then
        log "未有効化の拡張機能を再度有効化中..."
        for extension_uuid in "${missing_extensions[@]}"; do
            # Compile schemas before retrying
            compile_extension_schemas "$extension_uuid"

            if gnome-extensions enable "$extension_uuid" 2>/dev/null; then
                success "✓ $extension_uuid を有効化しました"
            else
                error "✗ $extension_uuid の有効化に失敗しました"
            fi
        done

        # Re-check missing extensions after retry
        enabled_list=$(gnome-extensions list --enabled)
        missing_extensions=()

        for extension_uuid in "${critical_extensions[@]}"; do
            if ! echo "$enabled_list" | grep -q "$extension_uuid"; then
                missing_extensions+=("$extension_uuid")
            fi
        done
    fi

    # Final status
    local final_enabled
    final_enabled=$(gnome-extensions list --enabled | wc -l)
    log "有効化された拡張機能の総数: $final_enabled"

    # Exit with error if critical extensions are still missing
    if [ ${#missing_extensions[@]} -gt 0 ]; then
        error "重要な拡張機能が有効化されていません: ${missing_extensions[*]}"
        exit 1
    fi
}

# Compile all extension schemas
compile_all_schemas() {
    log "全ての拡張機能のスキーマをコンパイル中..."

    local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
    local compiled_count=0

    if [ -d "$extensions_dir" ]; then
        for extension_dir in "$extensions_dir"/*; do
            if [ -d "$extension_dir" ]; then
                local extension_uuid=$(basename "$extension_dir")
                if compile_extension_schemas "$extension_uuid"; then
                    ((compiled_count++))
                fi
            fi
        done
    fi

    success "スキーマコンパイル完了: $compiled_count 個の拡張機能"
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
            check_dependencies
            check_gnome
            install_dependencies
            install_extensions
            enable_extensions
            apply_settings
            verify_installation
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
        "compile-schemas")
            check_gnome
            compile_all_schemas
            ;;
        *)
            echo "使用方法: $0 [install|export|apply-settings|enable|compile-schemas]"
            echo ""
            echo "コマンド:"
            echo "  install        - Extensions をインストールし設定を適用"
            echo "  export         - 現在の設定をエクスポート"
            echo "  apply-settings - 設定のみを適用"
            echo "  enable         - Extensions を有効化"
            echo "  compile-schemas - 全ての拡張機能のスキーマをコンパイル"
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
