# Gnome Extensions 自動セットアップ

このディレクトリには、Gnome Extensions を自動的にインストールし設定するスクリプトが含まれています。

## 📁 ファイル構成

```
gnome-extensions/
├── install-extensions.sh      # メインのインストールスクリプト
├── auto-install-extensions.sh # 依存関係込みの自動セットアップ
├── direct-install.sh          # API直接使用インストールスクリプト
├── test-install.sh           # テスト用インストールスクリプト
├── test-settings.sh          # 設定テスト用スクリプト
├── extensions-settings.dconf  # Extensions の設定
├── shell-settings.dconf       # Gnome Shell の設定
├── enabled-extensions.txt     # 有効な Extensions のリスト
├── disabled-extensions.txt    # 無効な Extensions のリスト
└── README.md                  # このファイル
```

## 🚀 使用方法

### 基本的な使用方法

```bash
# 🚀 完全自動セットアップ（推奨）- 依存関係から全て自動インストール
./auto-install-extensions.sh

# 📦 Extensions のみをインストール・設定
./install-extensions.sh install

# 📤 現在の設定をエクスポート
./install-extensions.sh export

# ⚙️ 設定のみを適用
./install-extensions.sh apply-settings

# 🔌 Extensions を有効化のみ
./install-extensions.sh enable

# 🔧 スキーマの再コンパイル
./install-extensions.sh compile-schemas

# 🧪 テスト用インストール（少数の拡張機能のみ）
./test-install.sh

# 🎯 直接インストール（extensions.gnome.org API を直接使用）
./direct-install.sh
```

### インストール方法の詳細

#### `auto-install-extensions.sh` - 完全自動セットアップ
依存関係のインストールから設定の適用まで、全てを自動で行います。初回セットアップに推奨。

#### `install-extensions.sh` - カスタムインストール
様々なオプションでカスタマイズしたインストールが可能です。設定の部分的な更新や特定の操作のみを実行する場合に使用。

#### `direct-install.sh` - 直接インストール
extensions.gnome.org の API を直接使用して拡張機能をダウンロード・インストールします。
- **特徴**: 依存関係チェックを行わず、即座にインストール開始
- **用途**: 高速インストール、他の方法で失敗した場合の代替手段
- **注意**: curl、unzip、jq が必要（事前に手動インストール要）

### Makefileからの実行

Makefileに以下のターゲットを追加することで、メインのセットアップ処理に組み込むことができます：

```makefile
# Gnome Extensions の設定をセットアップ
setup-gnome-extensions:
	@echo "🔧 Gnome Extensions の設定をセットアップ中..."
	@cd $(DOTFILES_DIR)/gnome-extensions && ./install-extensions.sh install
	@echo "✅ Gnome Extensions の設定が完了しました。"
```

## 📦 インストールされる Extensions

### 自動インストール・有効化される Extensions
- **Bluetooth Battery Indicator** - Bluetoothデバイスのバッテリー残量表示
- **Bluetooth Quick Connect** - Bluetoothデバイスの素早い接続
- **Move Clock** - 時計の位置移動
- **Tweaks & Extensions in System Menu** - システムメニューからTweaks・Extensions管理
- **Bring Out Submenu Of Power Off/Logout Button** - 電源・ログアウトメニューの改善
- **Privacy Menu** - プライバシー設定への素早いアクセス
- **Vertical Workspaces** - 垂直ワークスペース
- **Astra Monitor** - システムモニタ
- **Search Light** - 検索機能の改善

### 除外されたExtensions（手動管理）
以下のExtensionsは自動インストールの対象から除外されており、必要に応じて手動でインストール・設定してください：

- **Ubuntu AppIndicators** - システムデフォルト
- **Ubuntu Dock** - システムデフォルト
- **Desktop Icons NG (DING)** - システムデフォルト
- **User Themes** - カスタムテーマのサポート
- **GSConnect** - Android デバイスとの連携
- **Tiling Assistant** - ウィンドウタイリング支援
- **Clipboard Indicator** - クリップボード履歴
- **Custom Hot Corners** - ホットコーナーのカスタマイズ
- **System Monitor Next** - 詳細なシステムモニタ
- **Just Perfection** - GNOME Shell のカスタマイズ
- **Docker** - Docker コンテナ管理
- **Window App Switcher On Active Monitor** - アクティブモニタでのウィンドウ切り替え
- その他多数

## ⚙️ 動作要件

- **OS**: Ubuntu 22.04+ (GNOME/Unity デスクトップ環境)
- **必要なパッケージ**:
  - `gnome-shell-extensions`
  - `gnome-shell-extension-manager`
  - `chrome-gnome-shell`
  - `dconf-cli`
  - `curl`, `wget`, `unzip`
  - `python3-pip`

## 🔧 詳細設定

### 設定ファイルの説明

1. **extensions-settings.dconf**: Extensions の個別設定
   - 各 Extension の詳細な設定値
   - キーバインド、表示設定、動作設定など

2. **shell-settings.dconf**: Gnome Shell の基本設定
   - 有効/無効な Extensions リスト
   - お気に入りアプリケーション
   - その他 Shell 全体の設定

### カスタマイズ方法

現在の設定をエクスポートして、新しい環境に適用する場合：

```bash
# 現在の設定をエクスポート
./install-extensions.sh export

# 設定ファイルを編集
vim extensions-settings.dconf
vim shell-settings.dconf

# 設定を適用
./install-extensions.sh apply-settings
```

## 🚨 注意事項

1. **Extensions のインストール**:
   - インターネット接続が必要です
   - 一部の Extensions は extensions.gnome.org から自動ダウンロードされます
   - インストールに失敗した場合は手動インストールが必要な場合があります

2. **設定の適用**:
   - 設定変更後は GNOME Shell の再起動が推奨されます
   - Waylandセッションでは自動再起動ができないため、ログアウト/ログインが必要です

3. **互換性**:
   - GNOME Shell のバージョンによっては一部の Extensions が動作しない場合があります
   - Ubuntu のバージョンアップ時は Extensions の再確認が必要です

## 🔄 トラブルシューティング

### Extensions がインストールできない場合

```bash
# 手動で gnome-shell-extension-installer をインストール
pip3 install --user gnome-shell-extension-installer

# または
sudo apt install gnome-shell-extension-installer
```

### Extensions が有効化されない場合

```bash
# Extension Manager で手動確認
gnome-extensions-app

# またはコマンドラインで確認
gnome-extensions list
gnome-extensions enable <extension-uuid>
```

### 設定が反映されない場合

```bash
# GNOME Shell を再起動 (X11のみ)
killall -HUP gnome-shell

# または Alt+F2 → 'r' → Enter (X11のみ)

# Waylandの場合はログアウト/ログインが必要
```

## 📚 関連リンク

- [GNOME Extensions](https://extensions.gnome.org/)
- [GNOME Shell Extension Development](https://gjs.guide/extensions/)
- [Extension Manager](https://github.com/mjakeman/extension-manager)

## 📝 設定の更新

新しい Extensions を追加したり、設定を変更したい場合：

1. 手動で Extensions をインストール・設定
2. `./install-extensions.sh export` で現在の設定をエクスポート
3. スクリプト内の Extensions リストを更新
4. 新しい環境でテスト

---

**注意**: このスクリプトは現在の環境 (Ubuntu with GNOME/Unity) で動作確認されています。他の環境では動作しない可能性があります。
