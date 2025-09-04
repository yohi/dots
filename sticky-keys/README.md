# SHIFTキー固定モード対策

UbuntuのGNOME環境で時々発生するSHIFTキー固定モード（Sticky Keys）を即座に解除し、発生を防ぐためのツールセットです。

## 📁 ファイル構成

```text
sticky-keys/
├── install.sh                      # インストールスクリプト
├── fix-sticky-keys-instant.sh      # 即座解除スクリプト
├── disable-sticky-keys.sh          # 起動時無効化スクリプト
├── Fix-Sticky-Keys.desktop         # デスクトップショートカット
├── disable-sticky-keys.desktop     # 自動起動設定
└── README.md                       # このファイル
```

## 🚀 インストール方法

### dotfiles経由（推奨）

```bash
cd ~/dotfiles
make setup-sticky-keys
```

### 手動インストール

```bash
cd ~/dotfiles/sticky-keys
./install.sh
```

## 💡 使用方法

### SHIFTキー固定モードが発生した場合

1. **ホットキー（最も簡単）**
   ```
   Ctrl + Alt + S
   ```

2. **両SHIFTキー同時押し**
   - 左右のSHIFTキーを同時に押す

3. **デスクトップアイコン**
   - デスクトップの「SHIFTキー固定解除」アイコンをダブルクリック

4. **コマンドライン**
   ```bash
   ~/.local/bin/fix-sticky-keys-instant.sh
   ```

## 🛠️ 機能詳細

### 即座解除機能
- **ログアウト不要** でSHIFTキー固定モードを解除
- 複数の方法で確実に設定をリセット
- 解除完了時に通知を表示

### 自動防止機能
- ログイン時にSticky Keysを自動的に無効化
- 両SHIFTキー同時押しでの解除機能を有効化
- 音響フィードバックを無効化

### ホットキー機能
- `Ctrl + Alt + S` で即座に解除
- GNOMEのカスタムキーバインドとして設定

## 🔧 設定内容

インストール時に以下の設定が適用されます：

### GSettings設定
```bash
org.gnome.desktop.a11y.keyboard stickykeys-enable = false
org.gnome.desktop.a11y.keyboard stickykeys-two-key-off = true
org.gnome.desktop.a11y.keyboard stickykeys-modifier-beep = false
org.gnome.desktop.a11y always-show-universal-access-status = false
```

### ファイル配置
- `~/.local/bin/fix-sticky-keys-instant.sh` - 即座解除スクリプト
- `~/.local/bin/disable-sticky-keys.sh` - 起動時無効化スクリプト
- `~/.config/autostart/disable-sticky-keys.desktop` - 自動起動設定
- `~/Desktop/Fix-Sticky-Keys.desktop` - デスクトップショートカット

### カスタムキーバインド
- `Ctrl + Alt + S` → `fix-sticky-keys-instant.sh` 実行

## 🐛 トラブルシューティング

### ホットキーが効かない場合
```bash
# キーバインド設定の確認
gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings

# 再設定
cd ~/dotfiles
make setup-sticky-keys
```

### 設定が復帰してしまう場合
```bash
# 手動で再度無効化
~/.local/bin/disable-sticky-keys.sh

# または
gsettings set org.gnome.desktop.a11y.keyboard stickykeys-enable false
```

### 自動起動が働かない場合
```bash
# 自動起動設定の確認
ls -la ~/.config/autostart/disable-sticky-keys.desktop

# 権限の確認
chmod +x ~/.config/autostart/disable-sticky-keys.desktop
```

## 📝 ログ

設定の実行ログは以下に保存されます：
```
~/.config/sticky-keys-disable.log
```

## 🔄 アンインストール

```bash
# ファイルの削除
rm -f ~/.local/bin/fix-sticky-keys-instant.sh
rm -f ~/.local/bin/disable-sticky-keys.sh
rm -f ~/.config/autostart/disable-sticky-keys.desktop
rm -f ~/Desktop/Fix-Sticky-Keys.desktop

# カスタムキーバインドの削除
gsettings reset org.gnome.settings-daemon.plugins.media-keys custom-keybindings
```