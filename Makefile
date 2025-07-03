# Ubuntu開発環境セットアップ用Makefile
# 更新日: 2024年3月版

# 分割されたMakefileをinclude
include mk/variables.mk
include mk/help.mk
include mk/system.mk
include mk/install.mk
include mk/setup.mk
include mk/gnome.mk
include mk/mozc.mk
include mk/extensions.mk
include mk/clean.mk
include mk/main.mk

# デフォルトターゲット
.DEFAULT_GOAL := help

# このMakefileの内容は分割されたファイルに移動されました
# 以下のファイルに機能別に分割されています:
# - mk/variables.mk: 変数定義とPHONYターゲット
# - mk/help.mk: ヘルプメッセージ
# - mk/system.mk: システムレベル設定
# - mk/install.mk: アプリケーションインストール
# - mk/setup.mk: 設定セットアップ
# - mk/gnome.mk: GNOME関連
# - mk/mozc.mk: Mozc関連
# - mk/extensions.mk: 拡張機能関連
# - mk/clean.mk: クリーンアップ
# - mk/main.mk: 統合ターゲット

# 使用方法:
# make help - 利用可能なターゲット一覧を表示
# make setup-all - 全体のセットアップを実行
# make install-apps - アプリケーションのインストール
# make debug - デバッグ情報を表示
