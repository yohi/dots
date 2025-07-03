#!/bin/bash

# AppArmor プロファイル設定スクリプト
# Docker rootless で使用するためのAppArmorプロファイルを作成します

set -e

USER_NAME="${USER:-$(whoami)}"
PROFILE_PATH="/etc/apparmor.d/home.${USER_NAME}.bin.rootlesskit"

echo "🛡️  AppArmorの設定を確認中..."

# AppArmorによる制限の確認
if [ -f /proc/sys/kernel/apparmor_restrict_unprivileged_userns ] && [ "$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns)" = "1" ]; then
    echo "⚠️  AppArmorによりunprivileged user namespacesが制限されています"
    echo "🔧 AppArmorプロファイルを作成中..."

    # プロファイルが既に存在するかチェック
    if [ ! -f "$PROFILE_PATH" ]; then
        echo "📝 プロファイルファイルを作成中: $PROFILE_PATH"

        # AppArmorプロファイルの作成
        sudo tee "$PROFILE_PATH" > /dev/null <<EOF
# ref: https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces
abi <abi/4.0>,
include <tunables/global>

/home/${USER_NAME}/bin/rootlesskit flags=(unconfined) {
  userns,

  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/home.${USER_NAME}.bin.rootlesskit>
}
EOF

        echo "✅ AppArmorプロファイルを作成しました: $PROFILE_PATH"
        echo "🔄 AppArmorサービスを再起動中..."
        sudo systemctl restart apparmor.service
        echo "✅ AppArmorサービスが再起動されました"
    else
        echo "✅ AppArmorプロファイルは既に存在します"
    fi
else
    echo "✅ AppArmorによる制限はありません"
fi

echo "✅ AppArmor設定が完了しました"
