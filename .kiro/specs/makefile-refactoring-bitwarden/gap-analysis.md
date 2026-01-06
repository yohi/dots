# ギャップ分析: Makefile Bitwarden連携とリファクタリング

## 1. 概要
本ドキュメントは、既存のMakefileシステムと新機能要件（Bitwarden連携、構造改革、Devcontainer対応）との間のギャップを分析した結果である。
現状のコードベースはモジュール化が進んでいるものの、シークレット管理機能が完全に欠落しており、テスト環境も標準化されていない。

## 2. 現状分析 (Current State)

### 2.1 構成と構造
- **モジュール化**: `mk/` ディレクトリに機能別のMakefile（`system.mk`, `install.mk`等）が分割配置されており、ルートの `Makefile` でこれらをincludeしている。
- **命名規則**: 多くのターゲットはハイフン区切り（`install-homebrew`, `setup-vim`）に従っているが、`shortcuts.mk` や `menu.mk` には短縮形エイリアスも存在する。
- **依存関係管理**: `mk/install.mk` 内の `install-apps` ターゲットが `Brewfile` を参照している。

### 2.2 Bitwarden (CLI) の状況
- **インストール**: `Brewfile` に `brew "bitwarden-cli"` が含まれており、`make install-apps` を実行済みであれば `bw` コマンドは利用可能である。
- **利用状況**: 現在のMakefile群 (`mk/*.mk`) 内で `bw` コマンドを使用している箇所は存在しない。
- **シークレット管理**: APIキーや認証情報は、ユーザーの手動入力か、既存の環境変数に依存しており、体系的な注入メカニズムがない。

### 2.3 開発・テスト環境
- **Devcontainer**: プロジェクトルートに `.devcontainer` 設定が存在しない（`vim/.devcontainer` は存在するが、ドットファイル全体のテスト用ではない）。
- **テスト**: `make` ターゲットの動作を検証する自動化された手段がなく、ホスト環境に依存している。

## 3. ギャップ詳細 (Identified Gaps)

### 3.1 Bitwarden連携 (Critical)
- **欠如機能**:
  - `bw login` / `bw unlock` のステート管理（セッションキーのハンドリング）。
  - アイテム名やIDからシークレットを取得する共通関数またはターゲット。
  - シークレットが見つからない場合の安全なフォールバック処理。
- **課題**: Makeの各行は独立したシェルで実行されるため、`BW_SESSION` 環境変数の永続化が難しい。`eval $(make bw-unlock)` のようなパターンか、ファイルベースの一時保存（セキュリティリスクあり）か、都度入力かの設計判断が必要。

### 3.2 構造リファクタリング
- **必要アクション**:
  - `mk/bitwarden.mk` の新規作成。
  - 既存の「シークレットを必要とする可能性のあるターゲット」の洗い出し（現状は明示的な依存がないため、将来の拡張への準備となる）。
  - `help` ターゲットへのBitwarden関連コマンドの統合。

### 3.3 Devcontainer対応
- **欠如機能**: Makefile自体をクリーンな環境で実行・テストするためのDevcontainer定義。
- **必要アクション**:
  - `.devcontainer/devcontainer.json` および `Dockerfile` の作成。
  - テスト用コンテナ内での `bw` CLI 利用可否の検証（ホスト側の認証情報のパススルー等）。

## 4. 推奨実装アプローチ

### 4.1 Bitwardenモジュール (`mk/bitwarden.mk`)
- **ターゲット設計**:
  - `bw-login`: APIキーまたはメールアドレスでのログイン。
  - `bw-unlock`: セッションキー生成と表示（`eval`用）。
  - `bw-get-item-%`: パターンマッチで任意のアイテムを取得。
- **ヘルパー関数**:
  - Makeの `define` や `shell` 関数を使用し、`bw get password <name>` をラップしてエラーハンドリングを追加する。

### 4.2 Devcontainer
- **構成**:
  - Ubuntuベースのイメージを使用。
  - `make`, `gcc`, `git`, `curl` 等の基本ツールをプリインストール。
  - `bw` CLI もプリインストールし、テスト実行可能な状態にする。

### 4.3 互換性維持
- 既存の `make install` 等はBitwardenを必須とせず、オプション（`WITH_BW=1` など）または特定のターゲット（`make setup-secrets`）でのみ発動するように設計する。

## 5. リスクと対策
- **セッション管理**: Makeの制約上、セッションキーの維持が最大の課題。ユーザー体験を損なわないよう、`expect` コマンドやラッパースクリプトの併用も検討する。
- **セキュリティ**: ログ出力にシークレットが含まれないよう、`@` (silent command) を徹底し、ログ記録機能を実装する場合はフィルタリングを行う。

### 5.1 実装パターン評価

本セクションでは、セッション管理の具体的な実装パターンを評価し、選定基準を明確化する。

#### 5.1.1 外部スクリプトのパス・権限・配置

**パス解決の原則**:
- Makefile から呼び出すスクリプトは **相対パス** を使用する（`$(CURDIR)/mk/scripts/` または `./mk/scripts/`）
- スクリプト内部で他リソースを参照する場合は `"$(dirname "$0")"` で自身の位置を基準とする
- 絶対パスはCI環境やDevcontainerで破綻するため禁止

**権限設定**:
```bash
# スクリプト作成時の標準設定
umask 022                    # ファイル: 644, ディレクトリ: 755
chmod 755 mk/scripts/*.sh    # 実行権限付与
# シークレットを含む一時ファイル（非推奨だが必要な場合）
chmod 600 /tmp/bw-session    # 所有者のみ読み書き可
```

**推奨スクリプトディレクトリ**: `mk/scripts/`

| 項目 | 設定 |
|------|------|
| 配置先 | `mk/scripts/` |
| 命名規則 | `bw-*.sh`（Bitwarden関連）、`util-*.sh`（汎用） |
| 保守責任 | dotfiles リポジトリメンテナー（個人プロジェクトの場合は所有者） |
| バージョン管理 | Git管理対象、実行権限込みでコミット |

#### 5.1.2 セッション管理パターン比較

**Pattern A: eval-based session export**
```makefile
# 使用例: eval $(make bw-unlock)
bw-unlock:
	@echo "export BW_SESSION=$$(bw unlock --raw)"
```

| 観点 | 評価 |
|------|------|
| 堅牢性 | △ ユーザーが `eval` を忘れると動作しない |
| セキュリティ | ○ セッションはシェル変数のみ、ファイル残存なし |
| 複雑性 | ○ 最小限の実装 |
| テスト容易性 | △ シェル統合テストが必要 |
| 移植性 | ○ POSIX準拠シェルで動作 |

**Pattern B: expect automation**
```bash
#!/usr/bin/env expect
# mk/scripts/bw-unlock-expect.sh
spawn bw unlock
expect "Master password:"
send "$env(BW_MASTER_PASSWORD)\r"
expect eof
```

| 観点 | 評価 |
|------|------|
| 堅牢性 | △ `expect` のバージョン差異、プロンプト変更に弱い |
| セキュリティ | × パスワードを環境変数で渡す必要あり |
| 複雑性 | × 追加依存（expect）、デバッグ困難 |
| テスト容易性 | × モック困難、タイミング依存 |
| 移植性 | △ macOS/Linux OK、Alpine要追加インストール |

**Pattern C: standalone wrapper script**
```bash
#!/usr/bin/env bash
# mk/scripts/bw-session.sh
set -euo pipefail
if [[ -z "${BW_SESSION:-}" ]]; then
    BW_SESSION=$(bw unlock --raw)
    export BW_SESSION
fi
exec "$@"
# 使用例: ./mk/scripts/bw-session.sh bw get password myitem
```

| 観点 | 評価 |
|------|------|
| 堅牢性 | ○ 単一プロセス内で完結、状態管理が明確 |
| セキュリティ | ○ セッションはプロセス内変数のみ |
| 複雑性 | ○ bashのみ、ロジックが追跡可能 |
| テスト容易性 | ○ 単体テスト可能、モック容易 |
| 移植性 | ○ bash 4.0+ で動作（macOS/Linux/WSL） |

**推奨**: **Pattern C（standalone wrapper script）** を採用。堅牢性・テスト容易性・セキュリティのバランスが最も優れる。Pattern Aはシンプルなユースケースで補助的に使用可。

#### 5.1.3 Devcontainer認証情報パススルー

**方式1: バインドマウント（ホストの認証状態を共有）**
```jsonc
// .devcontainer/devcontainer.json
{
  "mounts": [
    "source=${localEnv:HOME}/.config/Bitwarden CLI,target=/home/vscode/.config/Bitwarden CLI,type=bind"
  ]
}
```

| 項目 | 内容 |
|------|------|
| 利点 | ホストでログイン済みなら即利用可、設定シンプル |
| 欠点 | ホスト側の状態に依存、マルチユーザー環境で競合リスク |
| セキュリティ考慮 | コンテナ侵害時にホストの認証情報が露出 |

**方式2: SSH Agent/Socketフォワーディング**
```jsonc
// .devcontainer/devcontainer.json
{
  "mounts": [
    "source=${localEnv:SSH_AUTH_SOCK},target=/ssh-agent,type=bind"
  ],
  "remoteEnv": {
    "SSH_AUTH_SOCK": "/ssh-agent"
  }
}
```
※ Bitwarden CLIは直接SSHキーを使用しないが、Git操作やSSH経由のシークレット取得に有用。

**方式3: 環境変数注入（CI向け）**
```yaml
# GitHub Actions例
env:
  BW_CLIENTID: ${{ secrets.BW_CLIENTID }}
  BW_CLIENTSECRET: ${{ secrets.BW_CLIENTSECRET }}
```

| 項目 | 内容 |
|------|------|
| 利点 | CI/CD環境で標準的、監査ログ対応 |
| 欠点 | ローカル開発では手動設定が必要 |
| セキュリティ考慮 | シークレットマネージャー経由で安全に注入可能 |

**検証手順**:
```bash
# 開発環境での検証
devcontainer exec bash -c 'bw status | jq .status'
# 期待値: "unlocked" または "locked"（認証情報パススルー成功）

# CI環境での検証（GitHub Actions）
- name: Verify Bitwarden CLI
  run: |
    bw login --apikey
    bw unlock --check && echo "Session valid"
```

**セキュリティ考慮事項サマリ**:

| 方式 | リスクレベル | 緩和策 |
|------|-------------|--------|
| バインドマウント | 中 | コンテナを信頼できるイメージに限定、読み取り専用マウント検討 |
| SSH Agent転送 | 低 | ソケット権限確認、不要時は無効化 |
| 環境変数注入 | 低〜中 | マスクログ設定、短命トークン使用 |

**推奨構成**: 開発環境ではバインドマウント（利便性優先）、CI環境では環境変数注入（セキュリティ優先）を使い分ける。

## 6. 結論
既存のコードベースはモジュール化されており拡張は容易である。`mk/bitwarden.mk` の追加とルートへのDevcontainer定義の追加により、既存機能を破壊することなく要件を満たすことが可能である。最大の技術的課題はMake内でのBitwardenセッションの取り回しである。
