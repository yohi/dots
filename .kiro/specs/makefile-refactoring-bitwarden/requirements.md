# 要件定義書

## はじめに
本仕様は、Makefileの構造的リファクタリングを行い、Bitwarden CLI連携によるセキュアな自動化フローとDevcontainer内での完全なテスト環境を構築するための要件を定義する。

## 要件

### 1. Makefile構造の再編と明確化
**目的:** メンテナとして、Makefileターゲットが整理されており、入口が明確であることを望む。これにより保守性と拡張性が向上する。

> **参照:** 詳細なターゲット定義とエイリアス移行マップは [architecture.md](./architecture.md) を参照。

#### 受け入れ基準

##### 1.1 デフォルトエントリポイントの明確化
1. The Makefile自動化システム shall ルートの `Makefile` を単一のエントリポイントとし、`make` または `make help` でヘルプを表示する。
2. The デフォルトターゲット (`all`) shall `help` ターゲットに変更され、利用可能なターゲット一覧を表示する。
3. When 利用者がターゲット一覧を確認する (`make help`), the Makefile自動化システム shall 公開ターゲットを網羅的に提示し、内部/プライベートターゲットを除外する。

##### 1.2 公開ターゲットの定義
1. The Makefile自動化システム shall 以下のカテゴリで公開ターゲットを定義する:
   - **システム設定:** `setup-system`
   - **パッケージインストール:** `install-packages-*` パターン (例: `install-packages-homebrew`, `install-packages-apps`, `install-packages-deb` 等)
   - **設定ファイルセットアップ:** `setup-config-*` パターン (例: `setup-config-vim`, `setup-config-zsh`, `setup-config-git` 等)
   - **管理・バックアップ:** `backup-config-*`, `export-config-*`, `update-*`, `check-*`, `clean`, `clean-*`
   - **プリセット実行:** `quick`, `dev-setup`, `full`, `minimal`
   - **段階的セットアップ:** `stage1`-`stage5`, `stage-status`, `stage-guide`
   - **フォント管理:** `fonts-*`
   - **メモリ管理:** `memory-*`
   - **AI開発ツール:** `codex`, `codex-*`, `superclaude-*`, `cc-sdd-*`
2. The 公開ターゲット shall `help.mk` に定義され、ヘルプメッセージに表示される。
3. The 内部/プライベートターゲット shall 先頭にアンダースコア (`_`) を付与し、ヘルプに表示しない。

##### 1.3 エイリアスポリシー（後方互換性）
1. The Makefile自動化システム shall `shortcuts.mk` で定義された既存の短縮エイリアスを維持する:
   - `i` → `install`, `s` → `setup`, `c` → `check-cursor-version`
   - `u` → `update-cursor`, `m` → `menu`, `h` → `help`
   - `s1`-`s5` → `stage1`-`stage5`, `ss` → `stage-status`, `sg` → `stage-guide`
2. When 旧ターゲット名（`install-homebrew` 等）が呼び出される, the Makefile自動化システム shall 新ターゲット名（`install-packages-homebrew`）へのエイリアスとして動作し、廃止予定の警告は表示しない。
3. The Makefile自動化システム shall 命名規則をハイフン区切りに統一するが、既存エイリアスは後方互換性のために無期限に維持する。

##### 1.4 命名規則の統一
1. The Makefile自動化システム shall 新規ターゲットに対してハイフン区切りの命名規則（`{action}-{domain}-{target}`）を適用する。
2. The ターゲット名 shall 動詞で始まる（例: `install-`, `setup-`, `update-`, `check-`, `clean-`）。

### 2. 既存ターゲット互換性の維持
**目的:** 利用者として、既存の操作が壊れずに継続して使えることを望む。これにより移行コストを抑えられる。

#### 受け入れ基準
1. When 既存の公開ターゲット名が呼び出される, the Makefile自動化システム shall 後方互換の振る舞いで実行する。
2. If 旧ターゲットが統合または廃止される, the Makefile自動化システム shall §2.1 で定義された廃止予定ターゲット移行マップを参照し、§2.2 で規定された出力先に廃止ガイダンスを出力し、§2.3 で定義されたタイムラインポリシーに従って動作する。
3. The Makefile自動化システム shall 失敗時に非0の終了コードを返す。

#### 設計決定: 廃止予定ターゲット移行ロードマップ

##### 2.1 廃止予定ターゲット移行マップ

**方式:** 静的マッピングファイルによる管理

**ファイルパス:** `makefiles/deprecated-targets.mk`

**フォーマット:**
```makefile
# Deprecated Target Mapping
# Format: OLD_TARGET -> NEW_TARGET | DEPRECATION_DATE | REMOVAL_DATE | STATUS
#
# STATUS values:
#   - warning: 警告を表示して新ターゲットにリダイレクト
#   - transition: 警告を表示して旧ターゲットの動作を実行（移行期間）
#   - removed: エラーを表示して終了

DEPRECATED_TARGETS := \
    install-homebrew:install-packages-homebrew:2026-02-01:2026-08-01:warning \
    install-apps:install-packages-apps:2026-02-01:2026-08-01:warning \
    install-deb:install-packages-deb:2026-02-01:2026-08-01:warning \
    setup-vim:setup-config-vim:2026-02-01:2026-08-01:warning \
    setup-zsh:setup-config-zsh:2026-02-01:2026-08-01:warning \
    setup-git:setup-config-git:2026-02-01:2026-08-01:warning

# Helper function to parse mapping
# Usage: $(call get_new_target,old-target-name)
define get_new_target
$(word 2,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef
```

**マップエントリの構造:**
| フィールド | 説明 | 例 |
|-----------|------|-----|
| OLD_TARGET | 廃止対象の旧ターゲット名 | `install-homebrew` |
| NEW_TARGET | 移行先の新ターゲット名 | `install-packages-homebrew` |
| DEPRECATION_DATE | 廃止予定の警告開始日（ISO 8601形式） | `2026-02-01` |
| REMOVAL_DATE | 完全削除予定日（ISO 8601形式） | `2026-08-01` |
| STATUS | 現在のステータス | `warning`, `transition`, `removed` |

##### 2.2 廃止ガイダンスの出力仕様

**出力先:** 標準エラー出力（stderr）

**理由:**
1. 通常の実行出力（stdout）を汚染しない
2. パイプライン処理で出力をフィルタリング可能
3. ログ収集ツールでの分離が容易

**出力フォーマット:**

**警告フェーズ（warning）:**
```
[DEPRECATED] Target 'install-homebrew' is deprecated and will be removed on 2026-08-01.
             Use 'install-packages-homebrew' instead.
             Migration: make install-packages-homebrew
```

**移行フェーズ（transition）:**
```
[DEPRECATED] Target 'install-homebrew' is deprecated and scheduled for removal on 2026-08-01.
             This target will be removed in the next major version.
             Migrate now: make install-packages-homebrew
             Proceeding with legacy behavior...
```

**削除済み（removed）:**
```
[ERROR] Target 'install-homebrew' has been removed as of 2026-08-01.
        Use 'install-packages-homebrew' instead.
        Run: make install-packages-homebrew
Exit code: 1
```

**ログレベル設定:**
| 環境変数 | 値 | 動作 |
|---------|-----|------|
| `MAKE_DEPRECATION_QUIET` | `1` | 廃止警告を抑制（removed 以外） |
| `MAKE_DEPRECATION_STRICT` | `1` | 警告を即座にエラーとして扱う（exit 1） |

##### 2.3 廃止タイムラインポリシー

**ライフサイクルフェーズ:**

| フェーズ | 期間 | 動作 | 終了コード |
|---------|------|------|-----------|
| 警告（warning） | 廃止開始日から6ヶ月間 | 警告を stderr に出力し、新ターゲットにリダイレクト | 0 |
| 移行（transition） | 削除予定日の1ヶ月前から | 警告を stderr に出力し、旧ターゲットの動作を実行 | 0 |
| 削除（removed） | 削除予定日以降 | エラーを stderr に出力し、処理を中断 | 1 |

**タイムラインルール:**
1. **最小警告期間:** 廃止開始から削除まで最低6ヶ月間の猶予を設ける
2. **事前通知:** 削除予定日の1ヶ月前から移行フェーズに移行
3. **セマンティックバージョニング:** メジャーバージョンアップ時のみターゲット削除を実施
4. **ドキュメント更新:** 廃止開始時に CHANGELOG.md および help ターゲットの出力を更新

**例外ルール:**
- セキュリティ上の理由がある場合、最小警告期間を短縮可能（ただし最低2週間）
- 短縮する場合は、理由を CHANGELOG.md に明記

##### 2.4 廃止予定ターゲット管理の受け入れ基準

1. The Makefile自動化システム shall 廃止予定ターゲット移行マップを `makefiles/deprecated-targets.mk` で管理する。
2. When 廃止予定ターゲットが呼び出される, the Makefile自動化システム shall 廃止ガイダンスを stderr に出力する。
3. When 廃止予定ターゲットが警告フェーズにある, the Makefile自動化システム shall 新ターゲットにリダイレクトして実行し、exit 0 で終了する。
4. When 廃止予定ターゲットが移行フェーズにある, the Makefile自動化システム shall 旧ターゲットの動作を実行し、exit 0 で終了する。
5. When 廃止予定ターゲットが削除済みフェーズにある, the Makefile自動化システム shall エラーメッセージを表示し、exit 1 で終了する。
6. When `MAKE_DEPRECATION_QUIET=1` が設定されている, the Makefile自動化システム shall 警告・移行フェーズの廃止ガイダンス出力を抑制する。
7. When `MAKE_DEPRECATION_STRICT=1` が設定されている, the Makefile自動化システム shall 警告・移行フェーズでも exit 1 で終了する。
8. The Makefile自動化システム shall 廃止開始から削除まで最低6ヶ月の猶予期間を遵守する。

#### 設計決定: WITH_BW フラグの動作仕様

##### 2.5 WITH_BW=1 セマンティクス
- `WITH_BW=1` を設定した場合のみ、Bitwarden連携機能が有効化される
- 環境変数としての設定（`export WITH_BW=1`）およびMake引数（`make target WITH_BW=1`）の両方をサポート
- `WITH_BW=0` または未設定の場合、Bitwarden連携は完全にスキップされる

##### 2.6 レガシーターゲットの WITH_BW 未設定時の動作
| ターゲット種別 | 動作 | 理由 |
|--------------|------|------|
| 汎用ターゲット（`install`, `setup`等） | Bitwarden連携部分をスキップし、他の処理は正常実行 | 後方互換性維持 |
| Bitwarden専用ターゲット（`bw-*`） | 警告表示後、exit 0 で終了 | 既存スクリプトの破壊防止 |

##### 2.7 CI/ローカル環境でのオプトイン・オプトアウト

**CI環境:**
```yaml
# GitHub Actions での有効化例
env:
  WITH_BW: 1
  BW_SESSION: ${{ secrets.BW_SESSION }}

# 無効化（デフォルト）- 環境変数を設定しない
```

**ローカル環境:**
```bash
# 一時的に有効化
make install WITH_BW=1

# セッション全体で有効化
export WITH_BW=1
make install

# 明示的に無効化
make install WITH_BW=0
```

##### 2.8 WITH_BW 受け入れ基準
1. When `WITH_BW` が未設定, the Makefile自動化システム shall すべてのBitwarden連携をスキップし、警告なく正常終了する。
2. When `WITH_BW=1` が設定されているがBitwarden環境が不完全, the Makefile自動化システム shall 具体的なエラーメッセージとともに exit 1 で終了する。
3. The Makefile自動化システム shall CI環境とローカル環境の両方で同一の `WITH_BW` セマンティクスを提供する。
4. When レガシースクリプトが `WITH_BW` を認識しない状態でターゲットを呼び出す, the Makefile自動化システム shall 破壊的変更なく従来通りの動作を維持する。

### 3. Bitwarden CLIによるシークレット取得
**目的:** セキュリティ担当として、シークレットを安全に取得して自動化フローに提供できることを望む。これにより手動入力や漏洩リスクを減らせる。

#### 受け入れ基準
1. When Bitwarden CLIにログイン済み（`bw status` で `status` が `"unlocked"` を返す）で対象シークレットが存在する, the Bitwarden連携フロー shall シークレットを取得して必要なコマンド実行に提供する。
2. If Bitwarden CLIが未ログインまたは利用不可, the Bitwarden連携フロー shall 明確なエラーを提示して処理を中断する。
3. If シークレットが見つからない, the Bitwarden連携フロー shall 対象名を示したエラーを返す。
4. The Bitwarden連携フロー shall シークレット値をログに出力しない。

#### WITH_BW フラグによる動作制御

##### 3.1 ターゲット別動作差分

| ターゲット | WITH_BW 未設定 | WITH_BW=1 |
|-----------|---------------|-----------|
| `make install` | Bitwarden連携をスキップし、通常のインストールのみ実行 | インストール後にシークレット設定を自動実行 |
| `make setup-secrets` | 警告を表示して即座に終了（exit 0） | Bitwardenからシークレットを取得して設定 |
| `make bw-unlock` | エラーを表示して終了（exit 1） | セッションキーを生成して出力 |
| `make bw-get-item-%` | エラーを表示して終了（exit 1） | 指定アイテムのシークレットを取得 |

##### 3.2 フォールバック動作定義

| 条件 | WITH_BW 未設定時 | WITH_BW=1 設定時 |
|------|-----------------|------------------|
| `bw` コマンド未導入 | スキップ（警告なし） | エラー終了（exit 1） |
| `bw` コマンド導入済み・未ログイン | スキップ（警告なし） | エラー終了（exit 1） |
| `bw` コマンド導入済み・ログイン済み・セッション未アンロック | スキップ（警告なし） | エラー終了（exit 1）、アンロック手順を案内 |
| `bw` コマンド導入済み・セッションアンロック済み | スキップ（警告なし） | 正常実行 |

##### 3.3 シナリオ別エラーメッセージと終了コード

**シナリオ1: bw コマンド未導入**
```
[ERROR] Bitwarden CLI (bw) is not installed.
        Install with: brew install bitwarden-cli
        Or run: make install-apps
Exit code: 1
```

**シナリオ2: 未ログイン状態**
```
[ERROR] Bitwarden CLI is not logged in.
        Run: bw login
        Or set BW_CLIENTID and BW_CLIENTSECRET for API key login.
Exit code: 1
```

**シナリオ3: ログイン済み・セッション未アンロック**
```
[ERROR] Bitwarden vault is locked.
        Run: eval $(make bw-unlock)
        Or: export BW_SESSION=$(bw unlock --raw)
Exit code: 1
```

**シナリオ4: シークレットが見つからない**
```
[ERROR] Secret not found: <item-name>
        Verify the item exists in your Bitwarden vault.
        Search with: bw list items --search "<item-name>"
Exit code: 1
```

**シナリオ5: WITH_BW 未設定で Bitwarden 専用ターゲットを実行**
```
[WARN] Bitwarden integration is disabled.
       To enable, run with: make <target> WITH_BW=1
       Skipping Bitwarden operations.
Exit code: 0
```

**シナリオ6: ネットワークエラーまたはAPIタイムアウト**
```
[ERROR] Failed to connect to Bitwarden server.
        Check your network connection and try again.
        If using self-hosted, verify BW_SERVER is set correctly.
Exit code: 1
```

#### 設計決定: BW_SESSION 永続化方式

##### 3.4 採用方式: eval パターン（推奨）

**決定:** `eval $(make bw-unlock)` パターンを採用する。

**理由:**
1. セッションキーがファイルシステムに永続化されないため、セキュリティリスクが最小
2. シェルセッション終了時に自動的にセッションが無効化される
3. Bitwarden公式ドキュメントで推奨されるパターンとの一貫性

**却下された代替案:**
| 方式 | 却下理由 |
|------|---------|
| ファイルベース保存 | セッションキーがディスクに残存するセキュリティリスク、パーミッション管理の複雑化 |
| インタラクティブ入力 | 自動化フローとの相性が悪い、CI環境での利用不可 |

##### 3.5 BW_SESSION 永続化の受け入れ基準

1. The Bitwarden連携フロー shall `make bw-unlock` でセッションキーを標準出力に出力し、`eval` で即座に環境変数として設定可能な形式を提供する。
2. The Bitwarden連携フロー shall セッションキーをファイルシステム、ログ、または履歴に保存しない。
3. When `BW_SESSION` 環境変数が既に設定されている, the Bitwarden連携フロー shall 再アンロックをスキップして既存セッションを使用する。
4. The Bitwarden連携フロー shall CI環境では `BW_SESSION` をシークレットとして事前設定することを前提とする。

##### 3.6 BW_SESSION 関連の失敗モード

| 失敗条件 | 動作 | 終了コード |
|---------|------|-----------|
| `BW_SESSION` 未設定かつ `bw unlock` 失敗 | マスターパスワード入力を促すメッセージを表示 | 1 |
| `BW_SESSION` 設定済みだがセッション期限切れ | 再アンロックを促すメッセージを表示 | 1 |
| `BW_SESSION` 設定済みだが無効なトークン | セッションの再取得を促すメッセージを表示 | 1 |
| `eval $(make bw-unlock)` の出力が不正 | パース可能な形式での出力失敗を報告 | 1 |

**期限切れセッションのエラーメッセージ:**
```
[ERROR] Bitwarden session has expired.
        Run: eval $(make bw-unlock)
        Or: export BW_SESSION=$(bw unlock --raw)
Exit code: 1
```

**無効トークンのエラーメッセージ:**
```
[ERROR] Invalid Bitwarden session token.
        Your session may have been invalidated.
        Run: eval $(make bw-unlock)
Exit code: 1
```

##### 3.7 Bitwarden CLI 状態判定ロジック

**決定:** `bw status` コマンドの JSON 出力を解析して状態を判定する。

**判定フロー:**

```
1. bw コマンドの存在確認
   └─ command -v bw >/dev/null 2>&1
   └─ 失敗時: "bw コマンド未導入" (シナリオ1)

2. bw status の実行と解析
   └─ bw status 2>/dev/null | jq -r '.status'
   └─ 結果に応じて分岐:
      ├─ "unauthenticated" → "未ログイン状態" (シナリオ2)
      ├─ "locked"          → "ログイン済み・セッション未アンロック" (シナリオ3)
      └─ "unlocked"        → "正常: シークレット取得可能"
```

**状態判定の実装コード例:**

```bash
# Bitwarden CLI の状態を取得する関数
_bw_check_status() {
    # 1. bw コマンドの存在確認
    if ! command -v bw >/dev/null 2>&1; then
        echo "not_installed"
        return 1
    fi
    
    # 2. bw status の実行（jq が利用可能な場合）
    if command -v jq >/dev/null 2>&1; then
        bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"
    else
        # jq がない場合は grep でパース
        local status_output
        status_output=$(bw status 2>/dev/null)
        if echo "$status_output" | grep -q '"status":"unlocked"'; then
            echo "unlocked"
        elif echo "$status_output" | grep -q '"status":"locked"'; then
            echo "locked"
        elif echo "$status_output" | grep -q '"status":"unauthenticated"'; then
            echo "unauthenticated"
        else
            echo "error"
        fi
    fi
}
```

**状態コードと対応するアクション:**

| `bw status` の結果 | 状態コード | 必要なアクション | 終了コード |
|-------------------|-----------|-----------------|-----------|
| コマンド未導入 | `not_installed` | `brew install bitwarden-cli` | 1 |
| `"unauthenticated"` | 未ログイン | `bw login` | 1 |
| `"locked"` | ログイン済み・ロック中 | `eval $(make bw-unlock)` | 1 |
| `"unlocked"` | 使用可能 | なし（正常） | 0 |
| その他/エラー | 不明 | ネットワーク確認、再試行 | 1 |

**受け入れ基準（状態判定）:**

1. The Bitwarden連携フロー shall `bw status` コマンドの JSON 出力から `status` フィールドを抽出して状態を判定する。
2. The Bitwarden連携フロー shall `status` が `"unlocked"` の場合のみシークレット操作を許可する。
3. When `status` が `"locked"` の場合, the Bitwarden連携フロー shall `eval $(make bw-unlock)` の実行を案内する。
4. When `status` が `"unauthenticated"` の場合, the Bitwarden連携フロー shall `bw login` の実行を案内する。
5. The Bitwarden連携フロー shall `jq` コマンドが利用できない環境でも `grep` によるフォールバック解析を提供する。

##### 3.8 bw-unlock ターゲット実装要件

**目的:** マスターパスワードを入力してセッションキーを取得し、シェル環境変数として設定可能な形式で出力する。

**使用方法:**

```bash
# 推奨: eval で環境変数に即座に設定
eval $(make bw-unlock)

# 確認: セッションが設定されたことを検証
echo $BW_SESSION  # 非空の文字列が出力される
bw status         # "unlocked" が返る
```

**出力形式:**

```bash
# 成功時の標準出力（eval で解釈される形式）
export BW_SESSION="<session-key>"

# エラー時は標準エラー出力にメッセージを出力し、標準出力は空
```

**実装要件:**

| 項目 | 要件 |
|------|------|
| 入力 | マスターパスワード（対話的入力 or `BW_PASSWORD` 環境変数） |
| 出力（成功時） | `export BW_SESSION="<session-key>"` 形式を標準出力に出力 |
| 出力（失敗時） | エラーメッセージを標準エラー出力に出力、標準出力は空 |
| 終了コード（成功） | 0 |
| 終了コード（失敗） | 1 |
| セッションキーのログ出力 | 禁止（`--raw` オプションで取得し、ログに残さない） |
| 既存セッションの扱い | `BW_SESSION` が設定済みかつ有効な場合はスキップ |

**環境変数:**

| 変数名 | 用途 | 必須 |
|--------|------|------|
| `BW_PASSWORD` | マスターパスワード（非対話的実行用） | CI環境では必須 |
| `BW_SESSION` | 既存セッションキー（設定済みの場合は再取得をスキップ） | 任意 |

**bw-unlock の Makefile 実装例:**

```makefile
.PHONY: bw-unlock
bw-unlock: ## Bitwarden セッションをアンロックして BW_SESSION を出力
ifndef WITH_BW
	@echo "[WARN] Bitwarden integration is disabled." >&2
	@echo "       To enable, run with: make bw-unlock WITH_BW=1" >&2
else
	@# 既存セッションの有効性チェック
	@if [ -n "$$BW_SESSION" ]; then \
		status=$$(BW_SESSION="$$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null); \
		if [ "$$status" = "unlocked" ]; then \
			echo "export BW_SESSION=\"$$BW_SESSION\""; \
			exit 0; \
		fi; \
	fi
	@# bw コマンドの存在確認
	@if ! command -v bw >/dev/null 2>&1; then \
		echo "[ERROR] Bitwarden CLI (bw) is not installed." >&2; \
		echo "        Install with: brew install bitwarden-cli" >&2; \
		exit 1; \
	fi
	@# ログイン状態の確認
	@status=$$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null); \
	if [ "$$status" = "unauthenticated" ]; then \
		echo "[ERROR] Bitwarden CLI is not logged in." >&2; \
		echo "        Run: bw login" >&2; \
		exit 1; \
	fi
	@# アンロック実行
	@if [ -n "$$BW_PASSWORD" ]; then \
		session=$$(echo "$$BW_PASSWORD" | bw unlock --raw 2>/dev/null); \
	else \
		session=$$(bw unlock --raw 2>/dev/null); \
	fi; \
	if [ -z "$$session" ]; then \
		echo "[ERROR] Failed to unlock Bitwarden vault." >&2; \
		echo "        Check your master password and try again." >&2; \
		exit 1; \
	fi; \
	echo "export BW_SESSION=\"$$session\""
endif
```

**エラーケース:**

| エラー条件 | 標準エラー出力 | 終了コード |
|-----------|---------------|-----------|
| `WITH_BW` 未設定 | 警告メッセージ + 有効化方法 | 0（警告のみ） |
| `bw` コマンド未導入 | インストール方法の案内 | 1 |
| 未ログイン状態 | `bw login` の実行案内 | 1 |
| マスターパスワード誤り | 再試行の案内 | 1 |
| ネットワークエラー | 接続確認の案内 | 1 |

**受け入れ基準（bw-unlock）:**

1. The `bw-unlock` ターゲット shall 成功時に `export BW_SESSION="<session-key>"` 形式を標準出力に出力する。
2. The `bw-unlock` ターゲット shall 失敗時にエラーメッセージを標準エラー出力に出力し、標準出力は空とする。
3. When `BW_SESSION` 環境変数が既に設定されており有効な場合, the `bw-unlock` ターゲット shall 再アンロックをスキップして既存セッションを再出力する。
4. When `BW_PASSWORD` 環境変数が設定されている場合, the `bw-unlock` ターゲット shall 非対話的にアンロックを実行する。
5. The `bw-unlock` ターゲット shall セッションキーをログファイル、コマンド履歴、または標準エラー出力に出力しない。
6. When `WITH_BW` が未設定の場合, the `bw-unlock` ターゲット shall 警告を表示して exit 0 で終了する（§3.1 の動作定義を参照）。

### 4. 自動化フローの安全性と再実行性
**目的:** 管理者として、安全に再実行できる自動化フローが必要である。これにより環境の破壊や二重実行のリスクを抑える。

#### 受け入れ基準
1. The Makefile自動化システム shall 再実行時に既存設定やインストール済み資産を破壊しない。
2. While 依存関係が未満たされている, the Makefile自動化システム shall 依存関係の不足を報告して失敗する。
3. When ターゲットが既に満たされている, the Makefile自動化システム shall §4.1 で定義された冪等性検出メソッドを使用してターゲットの充足状態を判定し、再インストールを行わずに完了する。

#### 設計決定: 冪等性検出戦略

##### 4.1 許可される冪等性検出メソッド

各ターゲットは以下のいずれかのメソッドを使用して「既に満たされている」状態を判定しなければならない。

| メソッド名 | 識別子 | 説明 | 適用例 |
|-----------|--------|------|--------|
| **ファイル存在チェック** | `FILE_EXISTS` | 特定のファイルまたはディレクトリの存在を確認 | 設定ファイルのシンボリックリンク、バイナリの存在 |
| **バージョンチェック** | `VERSION_CHECK` | コマンド出力から現在のバージョンを取得し、期待バージョンと比較 | CLI ツール、パッケージのインストール状態 |
| **マーカーファイル** | `MARKER_FILE` | `.done-<target>` 形式のマーカーファイルの存在を確認 | 複合的なセットアップ処理、一度限りの初期化処理 |
| **コマンド成功チェック** | `COMMAND_CHECK` | 特定のコマンドの終了コードで状態を判定 | サービスの起動状態、認証状態 |

##### 4.2 ターゲット別冪等性検出メソッド宣言

各公開ターゲットは、使用する冪等性検出メソッドを明示的に宣言しなければならない。

**パッケージインストールターゲット:**

| ターゲット | メソッド | 検出ロジック |
|-----------|---------|--------------|
| `install-packages-homebrew` | `COMMAND_CHECK` | `command -v brew >/dev/null 2>&1` |
| `install-packages-apps` | `VERSION_CHECK` | 各アプリの `--version` 出力を確認 |
| `install-packages-deb` | `COMMAND_CHECK` | `dpkg -l <package>` の終了コードを確認 |
| `install-packages-npm` | `COMMAND_CHECK` | `npm list -g <package>` の終了コードを確認 |
| `install-packages-pip` | `COMMAND_CHECK` | `pip show <package>` の終了コードを確認 |

**設定セットアップターゲット:**

| ターゲット | メソッド | 検出ロジック |
|-----------|---------|--------------|
| `setup-config-vim` | `FILE_EXISTS` | `~/.vimrc` または `~/.config/nvim/init.lua` の存在確認 |
| `setup-config-zsh` | `FILE_EXISTS` | `~/.zshrc` シンボリックリンクの存在と参照先の一致確認 |
| `setup-config-git` | `FILE_EXISTS` | `~/.gitconfig` の存在確認 |
| `setup-config-ssh` | `FILE_EXISTS` | `~/.ssh/config` の存在確認 |

**システムセットアップターゲット:**

| ターゲット | メソッド | 検出ロジック |
|-----------|---------|--------------|
| `setup-system` | `MARKER_FILE` | `.done-setup-system` マーカーファイルの存在確認 |
| `setup-secrets` | `MARKER_FILE` | `.done-setup-secrets` マーカーファイルの存在確認 |

**AI開発ツールターゲット:**

| ターゲット | メソッド | 検出ロジック |
|-----------|---------|--------------|
| `codex` | `VERSION_CHECK` | `codex --version` の出力を確認 |
| `superclaude-install` | `FILE_EXISTS` | `~/.claude/commands/` ディレクトリ内の必須ファイル存在確認 |
| `cc-sdd-install` | `FILE_EXISTS` | `.kiro/` ディレクトリ内の必須ファイル存在確認 |

##### 4.3 マーカーファイル標準パターン

**マーカーファイル配置ディレクトリ:**
```
${XDG_STATE_HOME:-$HOME/.local/state}/dots/
```

**命名規則:**
```
.done-<target-name>
```

**マーカーファイルフォーマット:**
```
# Makefile Target Completion Marker
# Target: <target-name>
# Completed: <ISO 8601 timestamp>
# Version: <version-string or "N/A">
# Checksum: <optional: SHA256 of relevant config>
```

**マーカーファイル作成の実装例:**
```makefile
MARKER_DIR := $(XDG_STATE_HOME)/dots
$(shell mkdir -p $(MARKER_DIR))

define create_marker
	@mkdir -p $(MARKER_DIR)
	@echo "# Makefile Target Completion Marker" > $(MARKER_DIR)/.done-$(1)
	@echo "# Target: $(1)" >> $(MARKER_DIR)/.done-$(1)
	@echo "# Completed: $$(date -Iseconds)" >> $(MARKER_DIR)/.done-$(1)
	@echo "# Version: $(2)" >> $(MARKER_DIR)/.done-$(1)
endef

define check_marker
	@test -f $(MARKER_DIR)/.done-$(1)
endef
```

**ターゲットでの使用例:**
```makefile
.PHONY: setup-system
setup-system: ## システム全体の初期セットアップ
	@if $(call check_marker,setup-system) 2>/dev/null; then \
		echo "[SKIP] setup-system is already completed."; \
		exit 0; \
	fi
	# ... セットアップ処理 ...
	$(call create_marker,setup-system,1.0.0)
```

##### 4.4 バージョンチェック標準パターン

**バージョン比較関数:**
```makefile
# バージョン文字列を比較（セマンティックバージョニング対応）
# 戻り値: 0=一致, 1=期待より古い, 2=期待より新しい
define version_compare
	$(shell \
		current=$(1); \
		expected=$(2); \
		if [ "$$current" = "$$expected" ]; then echo 0; \
		elif printf '%s\n%s\n' "$$expected" "$$current" | sort -V | head -n1 | grep -qx "$$expected"; then echo 2; \
		else echo 1; fi \
	)
endef

# 最小バージョン要件を満たしているかチェック
define check_min_version
	@current_ver=$$($(1) 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1); \
	if [ -z "$$current_ver" ]; then \
		echo "[CHECK] $(2) is not installed."; \
		exit 1; \
	fi; \
	if [ $$(printf '%s\n%s\n' "$(3)" "$$current_ver" | sort -V | head -n1) = "$(3)" ]; then \
		echo "[SKIP] $(2) $$current_ver >= $(3) (satisfied)"; \
		exit 0; \
	else \
		echo "[UPDATE] $(2) $$current_ver < $(3) (needs update)"; \
		exit 1; \
	fi
endef
```

**ターゲットでの使用例:**
```makefile
.PHONY: install-packages-homebrew
install-packages-homebrew: ## Homebrew のインストール
	@if command -v brew >/dev/null 2>&1; then \
		brew_ver=$$(brew --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'); \
		echo "[SKIP] Homebrew $$brew_ver is already installed."; \
		exit 0; \
	fi
	# ... インストール処理 ...
```

##### 4.5 ファイル存在チェック標準パターン

**シンボリックリンク検証関数:**
```makefile
# シンボリックリンクが期待する参照先を指しているかチェック
# $(1): リンクパス, $(2): 期待する参照先
define check_symlink
	@if [ -L "$(1)" ]; then \
		actual=$$(readlink -f "$(1)"); \
		expected=$$(readlink -f "$(2)"); \
		if [ "$$actual" = "$$expected" ]; then \
			echo "[SKIP] $(1) -> $(2) (already configured)"; \
			exit 0; \
		else \
			echo "[UPDATE] $(1) points to $$actual, expected $(2)"; \
			exit 1; \
		fi; \
	elif [ -e "$(1)" ]; then \
		echo "[CONFLICT] $(1) exists but is not a symlink"; \
		exit 1; \
	else \
		exit 1; \
	fi
endef
```

**ターゲットでの使用例:**
```makefile
.PHONY: setup-config-zsh
setup-config-zsh: ## Zsh 設定のセットアップ
	@if $(call check_symlink,$(HOME)/.zshrc,$(DOTFILES_DIR)/zsh/.zshrc) 2>/dev/null; then \
		exit 0; \
	fi
	# ... セットアップ処理 ...
```

##### 4.6 クリーンアップ・検証ルール

**マーカーファイルクリーンアップ:**
```makefile
.PHONY: clean-markers
clean-markers: ## 全てのマーカーファイルを削除（再セットアップを強制）
	@echo "[CLEAN] Removing all completion markers..."
	@rm -f $(MARKER_DIR)/.done-*
	@echo "[DONE] All markers removed. Next run will re-execute all targets."

.PHONY: clean-marker-%
clean-marker-%: ## 特定ターゲットのマーカーを削除
	@echo "[CLEAN] Removing marker for $*..."
	@rm -f $(MARKER_DIR)/.done-$*
```

**冪等性検証ターゲット:**
```makefile
.PHONY: check-idempotency
check-idempotency: ## 各ターゲットの冪等性状態を表示
	@echo "=== Idempotency Status ==="
	@echo ""
	@echo "Marker Files ($(MARKER_DIR)):"
	@ls -la $(MARKER_DIR)/.done-* 2>/dev/null || echo "  (no markers found)"
	@echo ""
	@echo "Package Installation Status:"
	@command -v brew >/dev/null 2>&1 && echo "  [✓] Homebrew: $$(brew --version | head -1)" || echo "  [ ] Homebrew: not installed"
	@command -v node >/dev/null 2>&1 && echo "  [✓] Node.js: $$(node --version)" || echo "  [ ] Node.js: not installed"
	@command -v python3 >/dev/null 2>&1 && echo "  [✓] Python: $$(python3 --version)" || echo "  [ ] Python: not installed"
	@echo ""
	@echo "Config Symlinks Status:"
	@test -L "$(HOME)/.zshrc" && echo "  [✓] .zshrc -> $$(readlink $(HOME)/.zshrc)" || echo "  [ ] .zshrc: not a symlink"
	@test -L "$(HOME)/.vimrc" && echo "  [✓] .vimrc -> $$(readlink $(HOME)/.vimrc)" || echo "  [ ] .vimrc: not a symlink"
```

**強制再実行オプション:**
```makefile
# FORCE=1 を指定すると冪等性チェックをスキップ
ifdef FORCE
  SKIP_IDEMPOTENCY_CHECK := true
endif

.PHONY: setup-system
setup-system:
ifndef SKIP_IDEMPOTENCY_CHECK
	@if $(call check_marker,setup-system) 2>/dev/null; then \
		echo "[SKIP] setup-system is already completed. Use FORCE=1 to re-run."; \
		exit 0; \
	fi
endif
	# ... セットアップ処理 ...
```

##### 4.7 冪等性検出の受け入れ基準

1. The Makefile自動化システム shall 各公開ターゲットに対して §4.1 で定義された冪等性検出メソッドのいずれかを使用する。
2. The Makefile自動化システム shall 新規ターゲット追加時に §4.2 のターゲット別冪等性検出メソッド宣言テーブルを更新する。
3. When `MARKER_FILE` メソッドを使用する, the Makefile自動化システム shall §4.3 で定義されたマーカーファイル標準パターンに従う。
4. When `VERSION_CHECK` メソッドを使用する, the Makefile自動化システム shall §4.4 で定義されたバージョンチェック標準パターンに従う。
5. When `FILE_EXISTS` メソッドを使用する, the Makefile自動化システム shall §4.5 で定義されたファイル存在チェック標準パターンに従う。
6. The Makefile自動化システム shall `clean-markers` および `clean-marker-%` ターゲットを提供し、マーカーファイルのクリーンアップを可能とする。
7. The Makefile自動化システム shall `check-idempotency` ターゲットを提供し、現在の冪等性状態を確認可能とする。
8. When `FORCE=1` が設定されている, the Makefile自動化システム shall 冪等性チェックをスキップしてターゲットを再実行する。
9. The Makefile自動化システム shall 冪等性検出によりスキップする場合、`[SKIP] <target> is already completed.` 形式のメッセージを標準出力に表示する。
10. The Makefile自動化システム shall マーカーファイルを `${XDG_STATE_HOME:-$HOME/.local/state}/dots/` ディレクトリに配置する。

### 5. Devcontainer内のテスト環境
**目的:** 開発者として、Devcontainer内で完全にテストできる環境が必要である。これによりホスト環境差異を排除できる。

> **参照:** 詳細な実装仕様（ベースイメージ選定理由、初期化コマンド、クレデンシャル連携、セッション管理、ホスト前提条件）は [devcontainer-implementation.md](./devcontainer-implementation.md) を参照。

#### 受け入れ基準
1. The Devcontainerテスト環境 shall Makefileターゲットのテストをコンテナ内で完結して実行できる。
2. When Devcontainerが起動する, the Devcontainerテスト環境 shall テストに必要な依存関係を提供する。
3. If ホスト環境の設定に依存する操作が必要, the Devcontainerテスト環境 shall 代替手順または必要条件を明示する。

#### 設計決定: Devcontainer 初期化仕様

##### 5.1 ベースイメージ
- **ベースイメージ:** `mcr.microsoft.com/devcontainers/base:ubuntu-22.04`
- **理由:** Microsoft公式のDevcontainer用イメージで、長期サポート版のUbuntuを使用。VS Code Dev Containers拡張との互換性が保証される。

##### 5.2 Bitwarden CLI インストール方式

**採用方式:** バージョン固定のインストールスクリプト

```dockerfile
# Bitwarden CLI installation
ARG BW_CLI_VERSION=2024.9.0
RUN curl -L "https://github.com/bitwarden/clients/releases/download/cli-v${BW_CLI_VERSION}/bw-linux-${BW_CLI_VERSION}.zip" -o /tmp/bw.zip \
    && unzip /tmp/bw.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/bw \
    && rm /tmp/bw.zip
```

**バージョン管理:**
- `devcontainer.json` の `build.args` でバージョンを指定可能
- CI環境と開発環境で同一バージョンを使用することを保証

##### 5.3 クレデンシャル提供方式

| 環境 | 提供方式 | 設定方法 |
|------|---------|---------|
| ローカルDevcontainer | ホストの環境変数をフォワード | `devcontainer.json` の `remoteEnv` で `BW_SESSION` を転送 |
| GitHub Codespaces | Codespacesシークレット | リポジトリ設定で `BW_SESSION` をシークレットとして登録 |
| CI環境 | GitHub Actions シークレット | ワークフローで `secrets.BW_SESSION` を環境変数として設定 |

**devcontainer.json 設定例:**
```json
{
  "remoteEnv": {
    "BW_SESSION": "${localEnv:BW_SESSION}",
    "WITH_BW": "${localEnv:WITH_BW}"
  }
}
```

##### 5.4 自動テストブートストラップ

**コンテナ起動時の自動実行（postCreateCommand）:**
```bash
# 依存関係の検証
make check-deps

# テスト用モックデータのセットアップ
make test-setup

# Bitwarden CLI の疎通確認（WITH_BW=1 の場合のみ）
if [ "${WITH_BW}" = "1" ]; then
  make bw-status || echo "[WARN] Bitwarden not configured for testing"
fi
```

**テスト実行コマンド:**
```bash
# 全テスト実行
make test

# Bitwarden連携テストのみ（モック使用）
make test-bw-mock

# 実際のBitwardenとの統合テスト（BW_SESSION必須）
make test-bw-integration WITH_BW=1
```

##### 5.5 Devcontainer テストの受け入れ基準

1. The Devcontainerテスト環境 shall コンテナビルド時に Bitwarden CLI `v2024.9.0` 以上をインストールする。
2. The Devcontainerテスト環境 shall `postCreateCommand` で依存関係の検証とテストセットアップを自動実行する。
3. When `BW_SESSION` がホスト環境で設定されている, the Devcontainerテスト環境 shall その値をコンテナ内に転送する。
4. The Devcontainerテスト環境 shall モックを使用したテスト（`test-bw-mock`）を Bitwarden認証なしで実行可能とする。
5. The Devcontainerテスト環境 shall 統合テスト（`test-bw-integration`）の実行には `BW_SESSION` の設定を必須とする。

---

## 設計レビュー承認

**重要:** 本要件定義書に記載された以下の設計決定は、実装開始前に正式な設計レビューと承認を必要とする。

### 関連ドキュメント

- [architecture.md](./architecture.md) - Makefile アーキテクチャ設計書（エントリポイント、公開ターゲット一覧、エイリアス移行マップ）
- [devcontainer-implementation.md](./devcontainer-implementation.md) - Devcontainer 実装仕様書（ベースイメージ、初期化コマンド、クレデンシャル連携、セッション管理）

### 承認必須項目

| 項番 | 設計決定 | セクション | 承認状態 ||
|-----|---------|-----------|---------|--|
| 1 | Makefile構造の再編（エントリポイント・公開ターゲット・エイリアスポリシー） | §1.1-1.4, [architecture.md](./architecture.md) | [ ] 未承認 |
| 2 | 廃止予定ターゲット移行ロードマップ（マップ形式・出力仕様・タイムラインポリシー） | §2.1-2.4 | [ ] 未承認 |
| 3 | WITH_BW フラグの動作仕様 | §2.5-2.8 | [ ] 未承認 |
| 4 | BW_SESSION 永続化方式（eval パターン採用） | §3.4-3.6 | [ ] 未承認 |
| 5 | Bitwarden CLI 状態判定ロジックと bw-unlock 実装要件 | §3.7-3.8 | [ ] 未承認 |
| 6 | 冪等性検出戦略（検出メソッド・マーカーファイル・バージョンチェック・クリーンアップ） | §4.1-4.7 | [ ] 未承認 |
| 7 | Devcontainer 初期化仕様 | §5.1-5.5 | [ ] 未承認 |

### 承認プロセス

1. **レビュー依頼:** 本ドキュメントを関係者に共有
2. **レビュー実施:** 各設計決定について技術的妥当性を確認
3. **承認記録:** 承認者が上記テーブルの承認状態を `[x] 承認済み (承認者名, 日付)` に更新
4. **実装開始:** 全項目が承認された後に実装フェーズへ移行

### 承認基準

- [ ] セキュリティ観点での妥当性確認
- [ ] CI/CD パイプラインとの互換性確認
- [ ] 既存ワークフローへの影響評価
- [ ] ドキュメントの完全性確認
