# GNOME Tweaks 設定システム

このディレクトリには、GNOME Tweaksの設定を自動化するためのスクリプトとツールが含まれています。

## 概要

`setup-gnome-tweaks.sh` スクリプトは、GNOME Tweaksで設定可能な項目を自動的に復元・適用するためのツールです。

## 機能

### 対象設定項目

- **外観設定**: テーマ、アイコン、カーソル、カラースキーム
- **フォント設定**: インターフェース、ドキュメント、等幅フォント
- **トップバー設定**: 時計、バッテリー表示など
- **ウィンドウ設定**: フォーカスモード、アニメーション
- **ワークスペース設定**: 動的ワークスペース、モニター設定
- **キーボード設定**: 入力ソース、キーマッピング
- **お気に入りアプリ**: ドックに表示するアプリケーション
- **拡張機能設定**: 有効/無効、個別設定
- **実験的機能**: X11フラクショナルスケーリングなど

### 現在適用される設定

- **テーマ**: Yaru-red (GTK/アイコン)、Yaru (カーソル/シェル)
- **フォント**: BlexSansJP Nerd Font
- **時計**: 秒表示、曜日表示有効
- **キーボード**: mozc + US配列、CapsLock無効
- **ワークスペース**: 動的ワークスペース、プライマリモニターのみ

## 使用方法

### コマンドライン直接実行

```bash
# 全設定を適用（GNOME Shell再起動確認あり）
./setup-gnome-tweaks.sh

# 全設定を適用（GNOME Shell再起動しない）
./setup-gnome-tweaks.sh --no-restart

# 現在の設定をバックアップ
./setup-gnome-tweaks.sh --backup

# 現在の設定をエクスポート
./setup-gnome-tweaks.sh --export

# バックアップから復元
./setup-gnome-tweaks.sh --restore /path/to/backup

# 拡張機能設定のみ適用
./setup-gnome-tweaks.sh --apply-extensions-only

# キーバインド設定のみ適用
./setup-gnome-tweaks.sh --apply-keybindings-only

# ヘルプ表示
./setup-gnome-tweaks.sh --help
```

### Makefile経由での実行

```bash
# 全設定を適用
make setup-gnome-tweaks

# 現在の設定をバックアップ
make backup-gnome-tweaks

# 現在の設定をエクスポート
make export-gnome-tweaks

# すべての設定セットアップ（Gnome Tweaks含む）
make setup-all
```

## 設定のカスタマイズ

### 設定値の変更

`setup-gnome-tweaks.sh` ファイル内の以下の関数を編集することで、適用される設定をカスタマイズできます：

- `apply_gnome_tweaks_settings()`: 基本設定
- `apply_extension_settings()`: 拡張機能設定
- `apply_keybindings()`: キーバインド設定

### 新しい設定の追加

1. 現在の設定をエクスポート:
   ```bash
   ./setup-gnome-tweaks.sh --export
   ```

2. エクスポートされたdconfファイルから必要な設定値を確認

3. スクリプトに新しい`apply_dconf_setting`呼び出しを追加

## バックアップとリストア

### 自動バックアップ

設定適用時に自動的にバックアップが作成されます：
- 場所: `~/.config/gnome-settings-backup-YYYYMMDD_HHMMSS/`
- 内容: desktop.dconf, shell.dconf, mutter.dconf

### 手動バックアップ/エクスポート

```bash
# バックアップ（ホームディレクトリ配下）
./setup-gnome-tweaks.sh --backup

# エクスポート（現在のディレクトリ）
./setup-gnome-tweaks.sh --export
```

### 復元

```bash
# バックアップから復元
./setup-gnome-tweaks.sh --restore /path/to/backup

# 手動復元
dconf load /org/gnome/desktop/ < desktop.dconf
dconf load /org/gnome/shell/ < shell.dconf
dconf load /org/gnome/mutter/ < mutter.dconf
```

## 現在有効な拡張機能

以下の拡張機能が有効化されます：

- `bluetooth-quick-connect@bjarosze.gmail.com`: Bluetooth Quick Connect
- `tweaks-system-menu@extensions.gnome-shell.fifi.org`: Tweaks System Menu
- `bluetooth-battery@michalw.github.com`: Bluetooth Battery Indicator
- `window-app-switcher-on-active-monitor@NiKnights.com`: Window App Switcher
- `ding@rastersoft.com`: Desktop Icons NG
- `ubuntu-dock@ubuntu.com`: Ubuntu Dock
- `Move_Clock@rmy.pobox.com`: Move Clock
- `BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm`: Power Options
- `PrivacyMenu@stuarthayhurst`: Privacy Menu
- `vertical-workspaces@G-dH.github.com`: Vertical Workspaces
- `search-light@icedman.github.com`: Search Light
- `monitor@astraext.github.io`: Astra Monitor

## トラブルシューティング

### 設定が反映されない場合

1. GNOME Shellを再起動:
   - X11: `Alt+F2` → `r` → Enter
   - Wayland: ログアウト・ログイン

2. システム再起動

### 拡張機能が有効にならない場合

1. Extension Managerで手動確認
2. 拡張機能の依存関係を確認
3. GNOME Shellのバージョン互換性を確認

### バックアップから復元時のエラー

1. dconfコマンドの存在確認: `which dconf`
2. 権限確認: `ls -la /path/to/backup`
3. ファイル形式確認: `file /path/to/backup/*.dconf`

## 注意事項

- **実行前のバックアップ推奨**: 設定適用前に必ずバックアップを作成してください
- **拡張機能の事前インストール**: 一部の拡張機能設定は、拡張機能がインストールされている場合のみ有効です
- **GNOME Shell再起動**: 設定反映のため、GNOME Shellの再起動またはログアウト・ログインが必要な場合があります
- **環境依存**: X11/Waylandセッション、GNOMEバージョンにより一部動作が異なる場合があります

## ファイル構成

```
gnome-settings/
├── README.md                           # このファイル
├── setup-gnome-tweaks.sh              # メイン設定スクリプト
└── gnome-settings-export-*/           # エクスポートされた設定
    ├── desktop.dconf                   # デスクトップ設定
    ├── shell.dconf                     # シェル設定
    ├── mutter.dconf                    # Mutter設定
    └── README.md                       # エクスポート情報
```

## 更新履歴

- **v1.0**: 初期バージョン
  - 基本的なGNOME Tweaks設定の自動化
  - バックアップ・復元機能
  - 拡張機能設定対応
  - Makefile統合 