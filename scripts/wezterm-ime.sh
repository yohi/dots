#!/bin/bash
# WezTerm IME対応起動スクリプト

# 環境変数の設定（IME統合を確実にする）
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

# Wayland環境でのIME統合のための追加設定
export IBUS_USE_PORTAL=1
export GTK_USE_PORTAL=1

# デバッグ情報（必要に応じて）
if [ "$1" = "--debug" ]; then
    echo "=== WezTerm IME Debug Info ==="
    echo "GTK_IM_MODULE: $GTK_IM_MODULE"
    echo "QT_IM_MODULE: $QT_IM_MODULE"
    echo "XMODIFIERS: $XMODIFIERS"
    echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
    echo "DISPLAY: $DISPLAY"
    echo "IBUS_USE_PORTAL: $IBUS_USE_PORTAL"
    echo "=============================="
    shift
fi

# IBusが起動していることを確認
if ! pgrep -x "ibus-daemon" > /dev/null; then
    echo "Warning: IBus daemon is not running. Starting it..."
    ibus-daemon -d
    sleep 2
fi

# WezTermを起動
exec /home/y_ohi/bin/wezterm "$@"
