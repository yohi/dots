# dotfiles setup Makefile
# Author: y_ohi
# Description: Comprehensive Ubuntu setup with applications and dotfiles configuration

.PHONY: all help system-setup install-homebrew install-apps install-deb-packages install-flatpak-packages \
        setup-vim setup-zsh setup-wezterm setup-vscode setup-cursor setup-git setup-docker setup-development setup-shortcuts \
        setup-all clean system-config

# デフォルトターゲット
all: help

# ヘルプメッセージ
help:
	@echo "🚀 Ubuntu開発環境セットアップ"
	@echo ""
	@echo "📋 利用可能なコマンド:"
	@echo "  make system-setup      - システムレベルの基本設定"
	@echo "  make install-homebrew  - Homebrewをインストール"
	@echo "  make install-apps      - Brewfileを使用してアプリケーションをインストール"
	@echo "  make install-deb       - DEBパッケージをインストール（IDE・ブラウザ含む）"
	@echo "  make install-flatpak   - Flatpakパッケージをインストール"
	@echo "  make setup-vim         - VIMの設定をセットアップ"
	@echo "  make setup-zsh         - ZSHの設定をセットアップ"
	@echo "  make setup-wezterm     - WEZTERMの設定をセットアップ"
	@echo "  make setup-vscode      - VS Codeの設定をセットアップ"
	@echo "  make setup-cursor      - Cursorの設定をセットアップ"
	@echo "  make setup-git         - Git設定をセットアップ"
	@echo "  make setup-docker      - Dockerの設定をセットアップ"
	@echo "  make setup-development - 開発環境の設定をセットアップ"
	@echo "  make setup-shortcuts   - キーボードショートカットの設定をセットアップ"
	@echo "  make setup-all         - すべての設定をセットアップ"
	@echo "  make clean             - シンボリックリンクを削除"
	@echo "  make help              - このヘルプメッセージを表示"
	@echo ""
	@echo "📦 推奨実行順序:"
	@echo "  1. make system-setup"
	@echo "  2. make install-homebrew"
	@echo "  3. make setup-all"
	@echo ""
	@echo "🌐 Google Chrome/Chromeベータについて:"
	@echo "  'make install-deb' でGoogle Chrome StableとBetaの両方がインストールされます"
	@echo ""
	@echo "👨‍💻 開発環境IDEについて:"
	@echo "  'make install-deb' で以下のIDEがインストールされます:"
	@echo "    - Visual Studio Code (公式リポジトリから)"
	@echo "    - Cursor IDE (AppImageとして /opt/cursor にインストール)"
	@echo ""
	@echo "📧 Eメールアドレスの設定:"
	@echo "  環境変数で指定: EMAIL=your@email.com make setup-git"
	@echo "  または実行時に入力プロンプトで設定可能"
	@echo ""
	@echo "💡 使用例:"
	@echo "  EMAIL=user@example.com make setup-all    # Eメール指定で全設定"
	@echo "  make setup-git                           # 実行時にEメール入力"

# 変数定義
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
CONFIG_DIR := $(HOME_DIR)/.config
USER := $(shell whoami)

# システムレベルの基本設定
system-setup:
	@echo "🔧 システムレベルの基本設定を開始..."
	
	# システムアップデート
	@sudo apt update && sudo apt -y upgrade
	
	# 日本語環境の設定
	@echo "🌏 日本語環境を設定中..."
	@sudo apt -y install language-pack-ja language-pack-ja-base
	
	# タイムゾーンを日本/東京に設定
	@echo "🕐 タイムゾーンをAsia/Tokyoに設定中..."
	@sudo timedatectl set-timezone Asia/Tokyo || true
	
	# ロケールの設定
	@echo "🌐 ロケールを設定中..."
	@sudo locale-gen ja_JP.UTF-8 || true
	@sudo update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja LC_ALL=ja_JP.UTF-8 || true
	
	# 日本語フォントのインストール
	@echo "🔤 日本語フォントをインストール中..."
	@sudo apt -y install fonts-noto-cjk fonts-noto-cjk-extra fonts-takao-gothic fonts-takao-mincho || true
	
	# 基本開発ツール
	@sudo apt -y install build-essential curl file wget software-properties-common
	
	# ユーザーディレクトリ管理パッケージをインストール
	@sudo apt -y install xdg-user-dirs-gtk
	
	# ホームディレクトリを英語名にする
	@LANG=C xdg-user-dirs-gtk-update
	
	# Ubuntu Japanese
	@sudo wget https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -P /etc/apt/trusted.gpg.d/ || true
	@sudo wget https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -P /etc/apt/trusted.gpg.d/ || true
	@sudo wget https://www.ubuntulinux.jp/sources.list.d/$$(lsb_release -cs).list -O /etc/apt/sources.list.d/ubuntu-ja.list || true
	@sudo apt update && sudo apt install -y ubuntu-defaults-ja || true
	
	# CapsLock -> Ctrl
	@setxkbmap -option "ctrl:nocaps" || true
	@sudo update-initramfs -u || true
	
	# 基本パッケージ
	@sudo apt install -y flatpak gdebi chrome-gnome-shell xclip xsel
	
	@echo "✅ システムレベルの基本設定が完了しました。"
	@echo "🌏 タイムゾーン: $$(timedatectl show --property=Timezone --value)"
	@echo "🌐 ロケール: $$(locale | grep LANG)"
	@echo "⚠️  言語設定を反映するため、システムの再起動を推奨します。"

# Homebrewのインストール
install-homebrew:
	@echo "🍺 Homebrewをインストール中..."
	@if ! command -v brew >/dev/null 2>&1; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$$PATH"' >> $(HOME_DIR)/.bashrc; \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
	else \
		echo "✅ Homebrewは既にインストールされています。"; \
	fi
	@echo "✅ Homebrewのインストールが完了しました。"

# Brewfileを使用してアプリケーションをインストール
install-apps:
	@echo "📦 アプリケーションをインストール中..."
	@if command -v brew >/dev/null 2>&1; then \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
		brew bundle --file=$(DOTFILES_DIR)/Brewfile; \
	else \
		echo "❌ Homebrewがインストールされていません。先に 'make install-homebrew' を実行してください。"; \
		exit 1; \
	fi
	@echo "✅ アプリケーションのインストールが完了しました。"

# DEBパッケージのインストール
install-deb:
	@echo "📦 DEBパッケージをインストール中..."
	@cd /tmp
	
	# 必要なリポジトリを追加
	@sudo add-apt-repository -y ppa:mattrose/terminator || true
	@sudo add-apt-repository -y ppa:hluk/copyq || true
	@sudo add-apt-repository -y ppa:remmina-ppa-team/remmina-next || true
	@sudo add-apt-repository -y ppa:boltgolt/howdy || true
	@sudo add-apt-repository -y ppa:cappelikan/ppa || true
	
	# Google Chromeリポジトリの追加
	@wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg || true
	@sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' || true
	
	# Visual Studio Codeリポジトリの追加
	@wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg || true
	@sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/ || true
	@sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' || true
	
	# Postmanリポジトリの追加
	@wget -qO- https://dl.pstmn.io/download/latest/linux64 -O /tmp/postman-linux-x64.tar.gz || true
	
	# GPGキーとリポジトリの追加
	@wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus-archive.gpg || true
	@sudo add-apt-repository -y "deb [arch=amd64] https://deb.tableplus.com/debian/22 tableplus main" || true
	
	@curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg || true
	@sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list' || true
	
	@curl -o- https://deb.packages.mattermost.com/setup-repo.sh | sudo bash || true
	
	# Slackリポジトリの追加
	@wget -qO- https://packagecloud.io/slacktechnologies/slack/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/slack-keyring.gpg || true
	@sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/slack-keyring.gpg] https://packagecloud.io/slacktechnologies/slack/debian/ jessie main" > /etc/apt/sources.list.d/slack.list' || true
	
	@sudo apt update
	
	# APTパッケージのインストール
	@sudo apt install -y tilix terminator google-chrome-stable google-chrome-beta \
		code kcachegrind blueman copyq mattermost-desktop meld \
		gnome-shell-extension-manager conky-all synaptic apt-xapian-index \
		gnome-tweaks gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 \
		remmina remmina-plugin-rdp remmina-plugin-secret \
		tableplus pgadmin4-desktop mainline slack-desktop || true
	
	# DEBファイルのダウンロードとインストール
	@cd /tmp && \
	wget -q https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb && \
	sudo gdebi -n dbeaver-ce_latest_amd64.deb || true
	
	@cd /tmp && \
	wget -q https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_8.0.31-1ubuntu22.04_amd64.deb && \
	sudo gdebi -n mysql-workbench-community_8.0.31-1ubuntu22.04_amd64.deb || true
	
	@cd /tmp && \
	wget -q https://github.com/Kong/insomnia/releases/download/core%402020.3.3/Insomnia.Core-2020.3.3.deb && \
	sudo gdebi -n Insomnia.Core-2020.3.3.deb || true
	
	@cd /tmp && \
	wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11664/wps-office_11.1.0.11664.XA_amd64.deb && \
	sudo gdebi -n wps-office_11.1.0.11664.XA_amd64.deb || true
	
	# Discord
	@cd /tmp && \
	echo "🎮 Discordをインストール中..." && \
	wget -q "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb && \
	sudo gdebi -n discord.deb || true && \
	echo "✅ Discordのインストールが完了しました" || true
	
	# Postman
	@cd /tmp && \
	echo "📮 Postmanをインストール中..." && \
	wget -q https://dl.pstmn.io/download/latest/linux64 -O postman-linux-x64.tar.gz && \
	sudo tar -xzf postman-linux-x64.tar.gz -C /opt/ && \
	sudo mv /opt/Postman /opt/postman || true && \
	echo "[Desktop Entry]" | sudo tee /usr/share/applications/postman.desktop > /dev/null && \
	echo "Name=Postman" | sudo tee -a /usr/share/applications/postman.desktop > /dev/null && \
	echo "Comment=API Development Environment" | sudo tee -a /usr/share/applications/postman.desktop > /dev/null && \
	echo "Exec=/opt/postman/Postman" | sudo tee -a /usr/share/applications/postman.desktop > /dev/null && \
	echo "Icon=/opt/postman/app/resources/app/assets/icon.png" | sudo tee -a /usr/share/applications/postman.desktop > /dev/null && \
	echo "Terminal=false" | sudo tee -a /usr/share/applications/postman.desktop > /dev/null && \
	echo "Type=Application" | sudo tee -a /usr/share/applications/postman.desktop > /dev/null && \
	echo "Categories=Development;" | sudo tee -a /usr/share/applications/postman.desktop > /dev/null && \
	echo "✅ Postmanのインストールが完了しました" || true

	# Cursor IDE
	@cd /tmp && \
	echo "📝 Cursor IDEをダウンロード中..." && \
	wget -q https://downloader.cursor.sh/linux/appImage/x64 -O cursor-latest.AppImage && \
	chmod +x cursor-latest.AppImage && \
	sudo mkdir -p /opt/cursor && \
	sudo mv cursor-latest.AppImage /opt/cursor/cursor.AppImage && \
	cd /tmp && \
	/opt/cursor/cursor.AppImage --appimage-extract > /dev/null 2>&1 && \
	if [ -f squashfs-root/cursor.png ]; then \
		sudo cp squashfs-root/cursor.png /opt/cursor/cursor.png; \
		ICON_PATH="/opt/cursor/cursor.png"; \
	elif [ -f squashfs-root/resources/app/assets/icon.png ]; then \
		sudo cp squashfs-root/resources/app/assets/icon.png /opt/cursor/cursor.png; \
		ICON_PATH="/opt/cursor/cursor.png"; \
	else \
		echo "⚠️  アイコンファイルが見つかりません。デフォルトアイコンを使用します。"; \
		ICON_PATH="applications-development"; \
	fi && \
	rm -rf squashfs-root && \
	echo "[Desktop Entry]" | sudo tee /usr/share/applications/cursor.desktop > /dev/null && \
	echo "Name=Cursor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
	echo "Comment=The AI-first code editor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
	echo "Exec=/opt/cursor/cursor.AppImage --no-sandbox" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
	echo "Icon=$$ICON_PATH" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
	echo "Terminal=false" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
	echo "Type=Application" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
	echo "Categories=Development;IDE;" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
	echo "✅ Cursor IDEのインストールが完了しました" || true
	
	# AWS Session Manager Plugin
	@cd /tmp && \
	curl -q "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
	sudo gdebi -n session-manager-plugin.deb || true
	
	@update-apt-xapian-index -vf || true
	
	@echo "✅ DEBパッケージのインストールが完了しました。"

# Flatpakパッケージのインストール（将来用）
install-flatpak:
	@echo "📦 Flatpakパッケージをインストール中..."
	@echo "ℹ️  現在Flatpakパッケージの設定はありません。必要に応じて追加してください。"

# VIMの設定をセットアップ
setup-vim:
	@echo "🖥️  VIMの設定をセットアップ中..."
	@mkdir -p $(HOME_DIR)/.vim
	@mkdir -p $(CONFIG_DIR)/nvim
	@mkdir -p $(CONFIG_DIR)/cspell
	@mkdir -p $(CONFIG_DIR)/denops_translate
	
	# Neovim設定ディレクトリ作成とシンボリックリンク
	@if [ -d "$(CONFIG_DIR)/nvim" ] && [ ! -L "$(CONFIG_DIR)/nvim" ]; then \
		echo "⚠️  既存のnvim設定をバックアップ中..."; \
		mv $(CONFIG_DIR)/nvim $(CONFIG_DIR)/nvim.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	@ln -sfn $(DOTFILES_DIR)/vim $(CONFIG_DIR)/nvim
	
	# 従来のVIM設定もリンク
	@ln -sfn $(DOTFILES_DIR)/vim/rc/vimrc $(HOME_DIR)/.vimrc
	@ln -sfn $(DOTFILES_DIR)/vim/rc/gvimrc $(HOME_DIR)/.gvimrc
	
	# 追加設定ディレクトリ
	@if [ -d "$(DOTFILES_DIR)/cspell" ]; then ln -sfn $(DOTFILES_DIR)/cspell $(CONFIG_DIR)/cspell; fi
	@if [ -d "$(DOTFILES_DIR)/vim/denops_translate" ]; then ln -sfn $(DOTFILES_DIR)/vim/denops_translate $(CONFIG_DIR)/denops_translate; fi
	
	@echo "✅ VIMの設定が完了しました。"

# ZSHの設定をセットアップ
setup-zsh:
	@echo "🐚 ZSHの設定をセットアップ中..."
	@mkdir -p $(DOTFILES_DIR)/zsh
	
	# Zinitのインストール
	@if [ ! -d "$(HOME_DIR)/.local/share/zinit" ]; then \
		bash -c "$$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"; \
	fi
	
	# 既存のzshrc設定ファイルが存在する場合はそれを使用、ない場合は基本設定を作成
	@if [ ! -f "$(DOTFILES_DIR)/zsh/zshrc" ]; then \
		echo "# ZSH Configuration" > $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# Generated by dotfiles Makefile" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# Enable Powerlevel10k instant prompt" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'if [[ -r "$${XDG_CACHE_HOME:-$$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh" ]]; then' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo '  source "$${XDG_CACHE_HOME:-$$HOME/.cache}/p10k-instant-prompt-$${(%):-%n}.zsh"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'fi' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# Homebrew PATH" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$$PATH"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# Zinit" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'ZINIT_HOME="$${XDG_DATA_HOME:-$${HOME}/.local/share}/zinit/zinit.git"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'source "$${ZINIT_HOME}/zinit.zsh"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# Load Powerlevel10k theme" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'zinit ice depth=1; zinit load romkatv/powerlevel10k' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# ZSH plugins" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'zinit load zsh-users/zsh-autosuggestions' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'zinit load zsh-users/zsh-syntax-highlighting' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'zinit load zsh-users/zsh-completions' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# Custom aliases" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias ll="ls -la"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias la="ls -A"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias l="ls -CF"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias ..="cd .."' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias ...="cd ../.."' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias grep="grep --color=auto"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias fgrep="fgrep --color=auto"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'alias egrep="egrep --color=auto"' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo "# Development tools" >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'export DOCKER_HOST=unix:///run/user/1000/docker.sock' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'export PATH=$$HOME/bin:$$PATH' >> $(DOTFILES_DIR)/zsh/zshrc; \
		echo 'export PATH=$$PATH:/sbin' >> $(DOTFILES_DIR)/zsh/zshrc; \
	else \
		echo "✅ 既存のzshrc設定ファイルを使用します: $(DOTFILES_DIR)/zsh/zshrc"; \
	fi
	
	# P10k設定ファイルの確認（既存があればそれを使用）
	@if [ ! -f "$(DOTFILES_DIR)/zsh/p10k.zsh" ] && [ ! -f "$(HOME_DIR)/.p10k.zsh" ]; then \
		echo "# Powerlevel10k configuration generated by dotfiles Makefile" > $(DOTFILES_DIR)/zsh/p10k.zsh; \
		echo "# Run 'p10k configure' to customize" >> $(DOTFILES_DIR)/zsh/p10k.zsh; \
	elif [ -f "$(DOTFILES_DIR)/zsh/p10k.zsh" ]; then \
		echo "✅ 既存のp10k設定ファイルを使用します: $(DOTFILES_DIR)/zsh/p10k.zsh"; \
	fi
	
	# シンボリックリンクを作成
	@if [ -f "$(HOME_DIR)/.zshrc" ] && [ ! -L "$(HOME_DIR)/.zshrc" ]; then \
		echo "⚠️  既存の.zshrcをバックアップ中..."; \
		mv $(HOME_DIR)/.zshrc $(HOME_DIR)/.zshrc.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	@ln -sfn $(DOTFILES_DIR)/zsh/zshrc $(HOME_DIR)/.zshrc
	
	@if [ -f "$(DOTFILES_DIR)/zsh/p10k.zsh" ]; then \
		if [ -f "$(HOME_DIR)/.p10k.zsh" ] && [ ! -L "$(HOME_DIR)/.p10k.zsh" ]; then \
			echo "⚠️  既存の.p10k.zshをバックアップ中..."; \
			mv $(HOME_DIR)/.p10k.zsh $(HOME_DIR)/.p10k.zsh.backup.$$(date +%Y%m%d_%H%M%S); \
		fi; \
		ln -sfn $(DOTFILES_DIR)/zsh/p10k.zsh $(HOME_DIR)/.p10k.zsh; \
	fi
	
	# ZSHをデフォルトシェルに設定
	@if ! grep -q "$$(which zsh)" /etc/shells; then \
		sudo sh -c "echo $$(which zsh) >> /etc/shells"; \
	fi
	@if [ "$$SHELL" != "$$(which zsh)" ]; then \
		echo "⚠️  ZSHをデフォルトシェルに設定するため、以下のコマンドを実行してください:"; \
		echo "    chsh -s $$(which zsh)"; \
	fi
	
	@echo "✅ ZSHの設定が完了しました。"

# WEZTERMの設定をセットアップ
setup-wezterm:
	@echo "🖥️  WEZTERMの設定をセットアップ中..."
	@mkdir -p $(CONFIG_DIR)/wezterm
	
	# 既存設定のバックアップ
	@if [ -f "$(CONFIG_DIR)/wezterm/wezterm.lua" ] && [ ! -L "$(CONFIG_DIR)/wezterm/wezterm.lua" ]; then \
		echo "⚠️  既存のwezterm設定をバックアップ中..."; \
		mv $(CONFIG_DIR)/wezterm/wezterm.lua $(CONFIG_DIR)/wezterm/wezterm.lua.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	
	# シンボリックリンクを作成
	@ln -sfn $(DOTFILES_DIR)/wezterm/wezterm.lua $(CONFIG_DIR)/wezterm/wezterm.lua
	
	@echo "✅ WEZTERMの設定が完了しました。"

# VS Codeの設定をセットアップ
setup-vscode:
	@echo "💻 VS Codeの設定をセットアップ中..."
	@mkdir -p $(CONFIG_DIR)/Code/User
	
	# 既存設定のバックアップ
	@if [ -f "$(CONFIG_DIR)/Code/User/settings.json" ] && [ ! -L "$(CONFIG_DIR)/Code/User/settings.json" ]; then \
		echo "⚠️  既存のVS Code settings.jsonをバックアップ中..."; \
		mv $(CONFIG_DIR)/Code/User/settings.json $(CONFIG_DIR)/Code/User/settings.json.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	@if [ -f "$(CONFIG_DIR)/Code/User/keybindings.json" ] && [ ! -L "$(CONFIG_DIR)/Code/User/keybindings.json" ]; then \
		echo "⚠️  既存のVS Code keybindings.jsonをバックアップ中..."; \
		mv $(CONFIG_DIR)/Code/User/keybindings.json $(CONFIG_DIR)/Code/User/keybindings.json.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	
	# シンボリックリンクを作成
	@ln -sfn $(DOTFILES_DIR)/vscode/settings.json $(CONFIG_DIR)/Code/User/settings.json
	@ln -sfn $(DOTFILES_DIR)/vscode/keybindings.json $(CONFIG_DIR)/Code/User/keybindings.json
	
	# 拡張機能のインストール
	@if command -v code >/dev/null 2>&1; then \
		echo "📦 VS Code拡張機能をインストール中..."; \
		if [ -f "$(DOTFILES_DIR)/vscode/extensions.list" ]; then \
			grep -v '^#' $(DOTFILES_DIR)/vscode/extensions.list | grep -v '^$$' | xargs -L 1 code --install-extension || true; \
		fi; \
		echo "✅ VS Code拡張機能のインストールが完了しました"; \
	else \
		echo "⚠️  VS Codeがインストールされていません。拡張機能のインストールをスキップします"; \
	fi
	
	@echo "✅ VS Codeの設定が完了しました。"

# Cursorの設定をセットアップ
setup-cursor:
	@echo "🖱️  Cursorの設定をセットアップ中..."
	@mkdir -p $(CONFIG_DIR)/Cursor/User
	
	# 既存設定のバックアップ
	@if [ -f "$(CONFIG_DIR)/Cursor/User/settings.json" ] && [ ! -L "$(CONFIG_DIR)/Cursor/User/settings.json" ]; then \
		echo "⚠️  既存のCursor settings.jsonをバックアップ中..."; \
		mv $(CONFIG_DIR)/Cursor/User/settings.json $(CONFIG_DIR)/Cursor/User/settings.json.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	@if [ -f "$(CONFIG_DIR)/Cursor/User/keybindings.json" ] && [ ! -L "$(CONFIG_DIR)/Cursor/User/keybindings.json" ]; then \
		echo "⚠️  既存のCursor keybindings.jsonをバックアップ中..."; \
		mv $(CONFIG_DIR)/Cursor/User/keybindings.json $(CONFIG_DIR)/Cursor/User/keybindings.json.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	
	# シンボリックリンクを作成
	@ln -sfn $(DOTFILES_DIR)/cursor/settings.json $(CONFIG_DIR)/Cursor/User/settings.json
	@ln -sfn $(DOTFILES_DIR)/cursor/keybindings.json $(CONFIG_DIR)/Cursor/User/keybindings.json
	
	@echo "✅ Cursorの設定が完了しました。"

# Git設定のセットアップ
setup-git:
	@echo "🖥️  Git設定をセットアップ中..."
	
	# 既存のGit設定をチェック
	@CURRENT_EMAIL=$$(git config --global user.email 2>/dev/null || echo ""); \
	CURRENT_NAME=$$(git config --global user.name 2>/dev/null || echo ""); \
	if [ -n "$$CURRENT_EMAIL" ] && [ -n "$$CURRENT_NAME" ]; then \
		echo "✅ Git設定は既に存在します:"; \
		echo "   Name: $$CURRENT_NAME"; \
		echo "   Email: $$CURRENT_EMAIL"; \
	else \
		echo "📧 Git設定をセットアップします。"; \
		if [ -n "$(EMAIL)" ]; then \
			git config --global user.name 'Yusuke Ohi'; \
			git config --global user.email '$(EMAIL)'; \
			echo "✅ Git設定完了 - Email: $(EMAIL)"; \
		else \
			read -p "Gitで使用するEメールアドレスを入力してください: " EMAIL_INPUT; \
			git config --global user.name 'Yusuke Ohi'; \
			git config --global user.email "$$EMAIL_INPUT"; \
			echo "✅ Git設定完了 - Email: $$EMAIL_INPUT"; \
		fi; \
	fi
	
	# SSH鍵の生成
	@if [ ! -f "$(HOME_DIR)/.ssh/id_ed25519" ]; then \
		echo "🔑 SSH鍵を生成中..."; \
		CURRENT_EMAIL=$$(git config --global user.email 2>/dev/null || echo ""); \
		if [ -n "$(EMAIL)" ]; then \
			ssh-keygen -t ed25519 -C '$(EMAIL)' -f $(HOME_DIR)/.ssh/id_ed25519 -N ''; \
		elif [ -n "$$CURRENT_EMAIL" ]; then \
			ssh-keygen -t ed25519 -C "$$CURRENT_EMAIL" -f $(HOME_DIR)/.ssh/id_ed25519 -N ''; \
		else \
			read -p "SSH鍵用のEメールアドレスを入力してください: " SSH_EMAIL; \
			ssh-keygen -t ed25519 -C "$$SSH_EMAIL" -f $(HOME_DIR)/.ssh/id_ed25519 -N ''; \
		fi; \
		echo "✅ SSH鍵が生成されました: $(HOME_DIR)/.ssh/id_ed25519.pub"; \
		echo "📋 公開鍵の内容:"; \
		cat $(HOME_DIR)/.ssh/id_ed25519.pub; \
	else \
		echo "✅ SSH鍵は既に存在します。"; \
	fi
	
	@echo "✅ Git設定が完了しました。"

# Docker設定のセットアップ
setup-docker:
	@echo "🐳 Docker設定をセットアップ中..."
	
	# Rootless Dockerのセットアップ
	@if ! command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then \
		echo "📦 Rootless Dockerをインストール中..."; \
		curl -fsSL https://get.docker.com/rootless | sh; \
	fi
	
	@dockerd-rootless-setuptool.sh install || true
	
	# 必要なパッケージをインストール
	@sudo apt-get install -y uidmap || true
	
	# サービスの設定
	@systemctl --user enable docker.service || true
	@systemctl --user start docker.service || true
	@sudo loginctl enable-linger $(USER) || true
	
	# Docker Composeのセットアップ
	@mkdir -p $(HOME_DIR)/.docker/cli-plugins
	@if command -v brew >/dev/null 2>&1; then \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
		ln -sfn $$(brew --prefix)/opt/docker-compose/bin/docker-compose $(HOME_DIR)/.docker/cli-plugins/docker-compose || true; \
	fi
	
	@echo "✅ Docker設定が完了しました。"

# 追加の開発環境設定
setup-development:
	@echo "⚙️  追加の開発環境設定を実行中..."
	
	# Tilixの設定
	@if [ -f "$(DOTFILES_DIR)/tilix/tilix.dconf" ]; then \
		echo "🖥️  Tilix設定を読み込み中..."; \
		dconf load /com/gexperts/Tilix/ < $(DOTFILES_DIR)/tilix/tilix.dconf || true; \
		echo "✅ Tilix設定が読み込まれました"; \
	else \
		echo "⚠️  Tilix設定ファイルが見つかりません: $(DOTFILES_DIR)/tilix/tilix.dconf"; \
	fi
	
	# logiopsの設定（設定ファイルが存在する場合）
	@if [ -f "$(DOTFILES_DIR)/logid/logid.cfg" ]; then \
		echo "🖱️  logiops設定をセットアップ中..."; \
		sudo apt install -y cmake libevdev-dev libudev-dev libconfig++-dev || true; \
		if [ ! -L "/etc/logid.cfg" ]; then \
			if [ -f "/etc/logid.cfg" ]; then \
				echo "⚠️  既存のlogid設定をバックアップ中..."; \
				sudo mv /etc/logid.cfg /etc/logid.cfg.backup.$$(date +%Y%m%d_%H%M%S) || true; \
			fi; \
		fi; \
		sudo ln -sfn $(DOTFILES_DIR)/logid/logid.cfg /etc/logid.cfg || true; \
		sudo systemctl enable logid || true; \
		echo "✅ logiops設定が完了しました"; \
		echo "ℹ️  logiopsサービスを開始するには: sudo systemctl start logid"; \
	else \
		echo "⚠️  logid設定ファイルが見つかりません: $(DOTFILES_DIR)/logid/logid.cfg"; \
	fi
	
	@echo "✅ 追加の開発環境設定が完了しました。"

# キーボードショートカットの設定
setup-shortcuts:
	@echo "⌨️  キーボードショートカットの設定を実行中..."
	
	# ウィンドウマネージャのキーバインド設定
	@if [ -f "$(DOTFILES_DIR)/gnome-shortcuts/wm-keybindings.dconf" ]; then \
		echo "🪟 ウィンドウマネージャのキーバインド設定を読み込み中..."; \
		dconf load /org/gnome/desktop/wm/keybindings/ < $(DOTFILES_DIR)/gnome-shortcuts/wm-keybindings.dconf || true; \
		echo "✅ ウィンドウマネージャのキーバインド設定が読み込まれました"; \
	else \
		echo "ℹ️  ウィンドウマネージャのキーバインド設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-shortcuts/wm-keybindings.dconf"; \
	fi
	
	# メディアキーのキーバインド設定
	@if [ -f "$(DOTFILES_DIR)/gnome-shortcuts/media-keybindings.dconf" ]; then \
		echo "🎵 メディアキーのキーバインド設定を読み込み中..."; \
		dconf load /org/gnome/settings-daemon/plugins/media-keys/ < $(DOTFILES_DIR)/gnome-shortcuts/media-keybindings.dconf || true; \
		echo "✅ メディアキーのキーバインド設定が読み込まれました"; \
	else \
		echo "ℹ️  メディアキーのキーバインド設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-shortcuts/media-keybindings.dconf"; \
	fi
	
	# カスタムキーバインド設定
	@if [ -f "$(DOTFILES_DIR)/gnome-shortcuts/custom-keybindings.dconf" ]; then \
		echo "🔧 カスタムキーバインド設定を読み込み中..."; \
		dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < $(DOTFILES_DIR)/gnome-shortcuts/custom-keybindings.dconf || true; \
		echo "✅ カスタムキーバインド設定が読み込まれました"; \
	else \
		echo "ℹ️  カスタムキーバインド設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-shortcuts/custom-keybindings.dconf"; \
	fi
	
	# ターミナルキーバインド設定（GNOME Terminal）
	@if [ -f "$(DOTFILES_DIR)/gnome-shortcuts/terminal-keybindings.dconf" ]; then \
		echo "🖥️  ターミナルキーバインド設定を読み込み中..."; \
		dconf load /org/gnome/terminal/legacy/keybindings/ < $(DOTFILES_DIR)/gnome-shortcuts/terminal-keybindings.dconf || true; \
		echo "✅ ターミナルキーバインド設定が読み込まれました"; \
	else \
		echo "ℹ️  ターミナルキーバインド設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-shortcuts/terminal-keybindings.dconf"; \
	fi
	
	@echo "✅ キーボードショートカットの設定が完了しました。"
	@echo "⚠️  設定を反映するため、一度ログアウト・ログインすることを推奨します。"

# すべての設定をセットアップ
setup-all: install-apps setup-vim setup-zsh setup-wezterm setup-vscode setup-git setup-docker setup-development setup-shortcuts
	@echo ""
	@echo "🎉 すべてのセットアップが完了しました！"
	@echo ""
	@echo "📋 次の手順を実行してください:"
	@echo "1. シェルを再起動するか、'source ~/.zshrc' を実行"
	@echo "2. ZSHをデフォルトシェルに設定: chsh -s $$(which zsh)"
	@echo "3. Neovimを起動してプラグインを確認"
	@echo "4. WezTermを再起動して設定を確認"
	@echo "5. P10k設定をカスタマイズ: p10k configure"
	@echo ""
	@echo "🔧 追加のパッケージが必要な場合:"
	@echo "  make install-deb       - DEBパッケージをインストール"
	@echo "  make install-flatpak   - Flatpakパッケージをインストール"

# クリーンアップ（シンボリックリンクを削除）
clean:
	@echo "🧹 シンボリックリンクを削除中..."
	
	# VIM関連のリンクを削除
	@if [ -L "$(CONFIG_DIR)/nvim" ]; then rm -f $(CONFIG_DIR)/nvim; fi
	@if [ -L "$(HOME_DIR)/.vimrc" ]; then rm -f $(HOME_DIR)/.vimrc; fi
	@if [ -L "$(HOME_DIR)/.gvimrc" ]; then rm -f $(HOME_DIR)/.gvimrc; fi
	@if [ -L "$(CONFIG_DIR)/cspell" ]; then rm -f $(CONFIG_DIR)/cspell; fi
	@if [ -L "$(CONFIG_DIR)/denops_translate" ]; then rm -f $(CONFIG_DIR)/denops_translate; fi
	
	# ZSH関連のリンクを削除
	@if [ -L "$(HOME_DIR)/.zshrc" ]; then rm -f $(HOME_DIR)/.zshrc; fi
	@if [ -L "$(HOME_DIR)/.p10k.zsh" ]; then rm -f $(HOME_DIR)/.p10k.zsh; fi
	
	# WEZTERM関連のリンクを削除
	@if [ -L "$(CONFIG_DIR)/wezterm/wezterm.lua" ]; then rm -f $(CONFIG_DIR)/wezterm/wezterm.lua; fi
	
	# VS Code関連のリンクを削除
	@if [ -L "$(CONFIG_DIR)/Code/User/settings.json" ]; then rm -f $(CONFIG_DIR)/Code/User/settings.json; fi
	@if [ -L "$(CONFIG_DIR)/Code/User/keybindings.json" ]; then rm -f $(CONFIG_DIR)/Code/User/keybindings.json; fi
	
	# Cursor関連のリンクを削除
	@if [ -L "$(CONFIG_DIR)/Cursor/User/settings.json" ]; then rm -f $(CONFIG_DIR)/Cursor/User/settings.json; fi
	@if [ -L "$(CONFIG_DIR)/Cursor/User/keybindings.json" ]; then rm -f $(CONFIG_DIR)/Cursor/User/keybindings.json; fi
	
	# その他の設定ファイル
	@if [ -L "/etc/logid.cfg" ]; then \
		echo "🖱️  logid設定リンクを削除中..."; \
		sudo rm -f /etc/logid.cfg; \
		echo "ℹ️  logidサービスを停止するには: sudo systemctl stop logid"; \
	fi
	
	@echo "✅ クリーンアップが完了しました。"

# デバッグ用：パスと環境変数を確認
debug:
	@echo "🔍 デバッグ情報:"
	@echo "DOTFILES_DIR: $(DOTFILES_DIR)"
	@echo "HOME_DIR: $(HOME_DIR)"
	@echo "CONFIG_DIR: $(CONFIG_DIR)"
	@echo "USER: $(USER)"
	@echo "EMAIL: $(if $(EMAIL),$(EMAIL),未設定 - 実行時に入力プロンプト表示)"
	@echo "Current directory: $(shell pwd)"
	@echo "Shell: $(SHELL)"
	@echo "Homebrew installed: $(shell command -v brew >/dev/null 2>&1 && echo 'Yes' || echo 'No')"
	@echo "ZSH installed: $(shell command -v zsh >/dev/null 2>&1 && echo 'Yes' || echo 'No')"
	@echo ""
	@echo "📧 Git設定確認:"
	@echo "Git user.name: $(shell git config --global user.name 2>/dev/null || echo '未設定')"
	@echo "Git user.email: $(shell git config --global user.email 2>/dev/null || echo '未設定')"
	@echo ""
	@echo "🔑 SSH鍵の状況:"
	@echo "SSH鍵存在: $(shell [ -f $(HOME_DIR)/.ssh/id_ed25519 ] && echo 'Yes' || echo 'No')" 