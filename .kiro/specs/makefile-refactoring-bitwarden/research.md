# リサーチログ

## 概要

本ドキュメントは、`makefile-refactoring-bitwarden` 機能の技術設計に先立って実施したディスカバリーとリサーチの結果を記録する。

**ディスカバリータイプ:** Full Discovery（拡張機能／複合統合）

**調査期間:** 2026-01-06

**デザインレビュー:** 2026-01-06 実施 → 3件のクリティカルイシューに対応済み

---

## リサーチログ

### トピック1: Bitwarden CLI セッション管理のベストプラクティス

**調査内容:**
- Bitwarden CLI (`bw`) の自動化フローにおけるセッション管理方式
- `BW_SESSION` 環境変数の安全な取り扱い
- CI/CD パイプラインでの非対話的認証方式

**情報源:**
- Bitwarden 公式ドキュメント
- コミュニティベストプラクティス (himmelwright.net, gruntwork.io)
- セキュリティガイドライン

**発見事項:**

1. **セッションキー管理:**
   - `bw unlock --raw` でセッショントークンのみを取得可能
   - `export BW_SESSION=$(bw unlock --raw)` パターンが推奨
   - セッションキーのファイルシステム永続化は避けるべき
   - シェルヒストリーへの保存も避ける

2. **API キー認証（CI向け）:**
   - `BW_CLIENTID` と `BW_CLIENTSECRET` による非対話的ログイン
   - Bitwarden Web App の Settings → Security → Keys で生成
   - 専用 API キーの発行を推奨（漏洩時の取り消し容易）

3. **セッション有効期限:**
   - アイドル状態で約15分で期限切れ
   - `bw sync` 等の API 操作でセッション延長可能
   - 明示的な `bw lock` でセッション終了

4. **セキュリティ考慮事項:**
   - マスターパスワードをスクリプト内で直接渡さない
   - 最小権限の原則を適用
   - ログ・監査の実装を推奨

**設計への影響:**
- `eval $(make bw-unlock)` パターンの採用が妥当
- セッションキーのログ出力禁止をルールとして定義
- CI 環境では `BW_SESSION` をシークレットとして事前設定

---

### トピック2: GNU Make 冪等性パターン

**調査内容:**
- Make ターゲットの冪等性実現方式
- マーカーファイルのベストプラクティス
- バージョンチェック・存在チェックの標準パターン

**情報源:**
- GNU Make 公式マニュアル
- Medium/StackOverflow ベストプラクティス記事

**発見事項:**

1. **Make のコア冪等性メカニズム:**
   - ターゲットファイルと prerequisites のタイムスタンプ比較
   - ターゲット名を実際の出力ファイルに対応させる
   - `.PHONY` で非ファイルターゲットを明示

2. **マーカーファイルパターン:**
   - 複合処理の完了を示す軽量ファイル
   - `touch .done-<target>` パターンが一般的
   - XDG_STATE_HOME への配置が推奨

3. **冪等性チェック方式:**
   - `FILE_EXISTS`: ファイル/ディレクトリ存在確認
   - `VERSION_CHECK`: コマンド出力でバージョン比較
   - `COMMAND_CHECK`: コマンド終了コードで状態判定
   - `MARKER_FILE`: 完了マーカーの存在確認

4. **強制再実行オプション:**
   - `FORCE=1` フラグで冪等性チェックをスキップ
   - CI でのクリーンビルドに有用

**設計への影響:**
- 要件で定義された4つの冪等性検出メソッドは妥当
- マーカーファイルディレクトリを `${XDG_STATE_HOME}/dots/` に統一
- `clean-markers` ターゲットでリセット機能を提供

---

### トピック3: Devcontainer シークレット管理

**調査内容:**
- Devcontainer での環境変数フォワーディング
- Docker シークレット管理方式
- GitHub Codespaces Secrets との統合

**情報源:**
- VS Code Dev Containers ドキュメント (containers.dev, code.visualstudio.com)
- Docker セキュリティベストプラクティス

**発見事項:**

1. **環境変数フォワーディング:**
   - `remoteEnv` で `${localEnv:VAR_NAME}` を使用
   - `containerEnv` は全プロセス対象、`remoteEnv` は VS Code サブプロセス対象
   - 機密情報のフォワーディングには注意が必要

2. **.env ファイル活用:**
   - 非機密設定に適切
   - `.gitignore` に追加必須
   - `runArgs: ["--env-file", "path/to/.env"]` で指定

3. **Docker Secrets:**
   - 機密情報はファイルとしてマウント（環境変数より安全）
   - Docker Compose の `secrets` セクションで管理
   - バージョン管理から除外

4. **GitHub Codespaces Secrets:**
   - リポジトリ設定で事前登録
   - 自動的にコンテナ環境変数として注入
   - `${containerEnv:VAR_NAME}` で参照

**設計への影響:**
- `BW_SESSION`, `WITH_BW` を `remoteEnv` でフォワード
- Codespaces Secrets をサポート
- モック機能で Bitwarden なしでもテスト可能に

---

## アーキテクチャパターン評価

### 評価対象パターン

| パターン | 説明 | 採用判定 |
|---------|------|---------|
| **分割 Makefile アーキテクチャ** | ドメイン別に `mk/*.mk` ファイルに分割し、ルート Makefile で include | 採用（既存パターン維持） |
| **冪等性検出レイヤー** | 各ターゲットに検出メソッドを割り当て、スキップロジックを標準化 | 採用 |
| **廃止予定ターゲット管理** | 静的マッピングファイルによるライフサイクル管理 | 採用 |
| **Bitwarden 統合レイヤー** | `WITH_BW` フラグによるオプトイン、状態判定関数の提供 | 採用 |
| **Devcontainer テストハーネス** | モック機能を含むコンテナベースのテスト環境 | 採用 |

---

## 設計決定

### DD-001: エントリポイント・命名規則

**決定:** 
- ルート `Makefile` を単一エントリポイントとする
- デフォルトターゲットを `help` に変更
- `{action}-{domain}-{target}` 命名規則を新規ターゲットに適用
- 既存エイリアスは後方互換性のため無期限維持

**理由:**
- ユーザビリティ向上（`make` で即座にヘルプ表示）
- 一貫した命名規則による discoverability 向上
- 既存スクリプト・ワークフローの破壊を回避

---

### DD-002: 廃止予定ターゲットライフサイクル

**決定:**
- `mk/deprecated-targets.mk` で静的マッピング管理
- 3フェーズ（warning → transition → removed）ライフサイクル
- 最低6ヶ月の猶予期間
- （`MAKE_DEPRECATION_WARN=1` または `MAKE_DEPRECATION_STRICT=1` の場合）stderr への廃止ガイダンス出力

**理由:**
- 予測可能な移行パスを利用者に提供
- 既存スクリプトの即座のブレークを防止
- セマンティックバージョニングとの整合性

---

### DD-003: Bitwarden セッション管理

**決定:**
- `eval $(make bw-unlock)` パターンを採用
- `bw status` JSON 解析による状態判定
- `jq` 未導入時は `grep` フォールバック
- セッションキーのログ/履歴保存を禁止

**理由:**
- Bitwarden 公式推奨パターンとの一貫性
- ファイルベース保存のセキュリティリスク回避
- 自動化と対話的使用の両方をサポート

---

### DD-004: 冪等性検出戦略

**決定:**
- 4メソッド（FILE_EXISTS, VERSION_CHECK, MARKER_FILE, COMMAND_CHECK）を標準化
- 各ターゲットに適切なメソッドを割り当て
- マーカーファイルは `${XDG_STATE_HOME}/dots/` に配置
- `FORCE=1` で強制再実行を許可

**実装関数マッピング:**

| メソッド識別子 | 実装関数名 | 用途 |
|--------------|-----------|------|
| `FILE_EXISTS` | `check_symlink` | シンボリックリンクの存在と参照先の検証 |
| `VERSION_CHECK` | `check_min_version` | コマンドバージョンの最小要件チェック |
| `MARKER_FILE` | `check_marker` / `create_marker` | 完了マーカーファイルの確認/作成 |
| `COMMAND_CHECK` | `check_command` | コマンドの存在確認 |

**関数シグネチャ:**
- `check_symlink(link_path, expected_target)` - シンボリックリンク検証
- `check_min_version(version_cmd, tool_name, min_version)` - バージョン比較
- `check_marker(target_name)` - マーカーファイル存在確認
- `create_marker(target_name, version)` - マーカーファイル作成
- `check_command(command_name)` - コマンド存在確認

**理由:**
- ターゲット特性に応じた最適な検出方式の選択
- XDG 準拠によるクリーンなホームディレクトリ
- CI/デバッグ用の再実行オプション確保
- 実装関数名の明示による設計と実装の整合性確保

---

### DD-005: Devcontainer テスト環境

**決定:**
- Ubuntu 22.04 LTS ベースイメージを採用
- Bitwarden CLI v2024.9.0 をバージョン固定でインストール
- `remoteEnv` による `BW_SESSION` フォワード
- モック bw コマンドによる非認証テストサポート

**理由:**
- 22.04 LTS のエコシステム成熟度と長期サポート
- CI 環境との一貫性（GitHub Actions ubuntu-22.04）
- Bitwarden なしでも開発・テストを継続可能

---

## リスク分析

| リスク | 影響度 | 発生可能性 | 緩和策 |
|-------|-------|-----------|-------|
| Bitwarden セッション期限切れによるフロー中断 | 中 | 高 | keepalive スクリプト、明確なエラーメッセージと復旧手順 |
| 廃止予定ターゲットの誤った削除タイミング | 高 | 低 | 最低6ヶ月ポリシー、CHANGELOG への記録 |
| マーカーファイル破損・不整合 | 低 | 低 | `clean-markers` ターゲット、`FORCE=1` オプション |
| Devcontainer ビルド失敗（ネットワーク問題等） | 中 | 中 | Dockerfile キャッシュ活用、明確なエラーメッセージ |
| jq 未導入環境での Bitwarden 状態判定失敗 | 低 | 中 | grep フォールバックロジック実装 |

---

## 並列化の考慮事項

タスク生成時に以下の依存関係を考慮：

1. **独立タスク（並列実行可能）:**
   - `help.mk` の更新
   - `deprecated-targets.mk` の作成
   - 冪等性ヘルパー関数の実装
   - Devcontainer 設定ファイルの作成

2. **依存タスク（順次実行）:**
   - Bitwarden 連携ターゲット実装 → Bitwarden テスト作成
   - 冪等性ヘルパー関数 → 各ターゲットへの適用
   - Devcontainer 作成 → 統合テスト実装

---

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|-----|---------|
| 1.0 | 2026-01-06 | 初版作成 - Full Discovery 実施、設計決定・リスク分析を記録 |
| 1.1 | 2026-01-06 | デザインレビュー対応 - 3件のクリティカルイシュー（パース時副作用、jq依存矛盾、エイリアス責務分散）への設計決定を追加 |
