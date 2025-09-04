#!/bin/bash
# GSettings スキーマとキーの検証スクリプト

set -euo pipefail

echo "🔍 GSettings スキーマとキーの検証中..."
echo "================================================"

# スキーマの有無確認
echo "📋 スキーマの有無確認:"
if gsettings list-schemas | grep -q '^org\.gnome\.desktop\.a11y\.keyboard$'; then
    echo "✅ org.gnome.desktop.a11y.keyboard スキーマ: 存在"
else
    echo "❌ org.gnome.desktop.a11y.keyboard スキーマ: 存在しない"
    exit 1
fi

if gsettings list-schemas | grep -q '^org\.gnome\.desktop\.a11y$'; then
    echo "✅ org.gnome.desktop.a11y スキーマ: 存在"
else
    echo "❌ org.gnome.desktop.a11y スキーマ: 存在しない"
fi

if gsettings list-schemas | grep -q '^org\.gnome\.desktop\.interface$'; then
    echo "✅ org.gnome.desktop.interface スキーマ: 存在"
else
    echo "❌ org.gnome.desktop.interface スキーマ: 存在しない"
fi

echo ""
echo "🔑 キー一覧確認:"
echo "org.gnome.desktop.a11y.keyboard のキー:"
gsettings list-keys org.gnome.desktop.a11y.keyboard | sort

echo ""
echo "stickykeys 関連キーのみ:"
gsettings list-keys org.gnome.desktop.a11y.keyboard | grep stickykeys || echo "stickykeys 関連キーが見つかりません"

echo ""
echo "📊 現在の設定値:"
echo "stickykeys-enable: $(gsettings get org.gnome.desktop.a11y.keyboard stickykeys-enable 2>/dev/null || echo 'キーが存在しません')"
echo "stickykeys-two-key-off: $(gsettings get org.gnome.desktop.a11y.keyboard stickykeys-two-key-off 2>/dev/null || echo 'キーが存在しません')"
echo "stickykeys-modifier-beep: $(gsettings get org.gnome.desktop.a11y.keyboard stickykeys-modifier-beep 2>/dev/null || echo 'キーが存在しません')"

echo ""
echo "🔧 書き込み可否確認:"
echo "stickykeys-enable: $(gsettings writable org.gnome.desktop.a11y.keyboard stickykeys-enable 2>/dev/null && echo '書き込み可能' || echo '書き込み不可')"

echo ""
echo "✅ 検証完了"
