# 実装タスク

## 要件仕様書リファレンス

本タスクリストは以下の要件仕様書に基づいて作成されている。各タスクに記載された `Requirements: X.X` は [requirements.md](./requirements.md) の該当セクションを参照する。

| 要件ID | 要件概要 | 関連設計セクション |
|--------|---------|-------------------|
| 1.1 | デフォルトエントリポイントの明確化 | [design.md §3.3.4](./design.md#334-エントリポイントとヘルプシステム) |
| 1.2 | 公開ターゲットの定義 | [architecture.md](./architecture.md) |
| 1.3 | エイリアスポリシー（後方互換性） | [design.md §3.3.3a](./design.md#333a-短縮エイリアスの定義-mkshortcutsmk) |
| 1.4 | 命名規則の統一 | [requirements.md §1.4](./requirements.md) |
| 2.1 | 廃止予定ターゲット移行マップ | [requirements.md §2.1](./requirements.md) |
| 2.2 | 廃止ガイダンスの出力仕様 | [requirements.md §2.2](./requirements.md) |
| 2.3 | 廃止タイムラインポリシー | [requirements.md §2.3](./requirements.md) |
| 2.4 | 廃止予定ターゲット管理の受け入れ基準 | [requirements.md §2.4](./requirements.md) |
| 2.5 | WITH_BW=1 セマンティクス | [requirements.md §2.5](./requirements.md) |
| 2.6 | レガシーターゲットの WITH_BW 未設定時の動作 | [requirements.md §2.6](./requirements.md) |
| 2.7 | CI/ローカル環境でのオプトイン・オプトアウト | [requirements.md §2.7](./requirements.md) |
| 2.8 | WITH_BW 受け入れ基準 | [requirements.md §2.8](./requirements.md) |
| 3.1 | ターゲット別動作差分 | [requirements.md §3.1](./requirements.md) |
| 3.2 | フォールバック動作定義 | [requirements.md §3.2](./requirements.md) |
| 3.3 | シナリオ別エラーメッセージと終了コード | [requirements.md §3.3](./requirements.md) |
| 3.4 | 採用方式: eval パターン（推奨） | [requirements.md §3.4](./requirements.md) |
| 3.5 | BW_SESSION 永続化の受け入れ基準 | [requirements.md §3.5](./requirements.md) |
| 3.6 | BW_SESSION 関連の失敗モード | [requirements.md §3.6](./requirements.md) |
| 3.7 | Bitwarden CLI 状態判定ロジック | [requirements.md §3.7](./requirements.md) |
| 3.8 | bw-unlock ターゲット実装要件 | [requirements.md §3.8](./requirements.md) |
| 4.1 | 許可される冪等性検出メソッド | [requirements.md §4.1](./requirements.md) |
| 4.2 | ターゲット別冪等性検出メソッド宣言 | [requirements.md §4.2](./requirements.md) |
| 4.3 | マーカーファイル標準パターン | [requirements.md §4.3](./requirements.md) |
| 4.4 | バージョンチェック標準パターン | [requirements.md §4.4](./requirements.md) |
| 4.5 | ファイル存在チェック標準パターン | [requirements.md §4.5](./requirements.md) |
| 4.6 | クリーンアップ・検証ルール | [requirements.md §4.6](./requirements.md) |
| 4.7 | 冪等性検出の受け入れ基準 | [requirements.md §4.7](./requirements.md) |
| 5.1 | ベースイメージ | [devcontainer-implementation.md](./devcontainer-implementation.md) |
| 5.2 | Bitwarden CLI インストール方式 | [devcontainer-implementation.md](./devcontainer-implementation.md) |
| 5.3 | クレデンシャル提供方式 | [devcontainer-implementation.md](./devcontainer-implementation.md) |
| 5.4 | 自動テストブートストラップ | [devcontainer-implementation.md](./devcontainer-implementation.md) |
| 5.5 | Devcontainer テストの受け入れ基準 | [devcontainer-implementation.md](./devcontainer-implementation.md) |

---

## 機能相互作用マトリックス

本仕様の3つの主要機能（廃止管理、Bitwarden連携、冪等性）間の相互作用を定義する。

### 相互作用テーブル

| 機能A | 機能B | 相互作用シナリオ | 期待される動作 |
|-------|-------|-----------------|---------------|
| **廃止管理** | **Bitwarden連携** | 廃止予定ターゲット（例: `setup-secrets`）が `bw-*` 機能を内包 | 新ターゲットへリダイレクト後、WITH_BW チェックを適用。旧ターゲット経由でも WITH_BW=1 必須 |
| **廃止管理** | **Bitwarden連携** | `bw-*` ターゲット自体が将来廃止対象になった場合 | 廃止マップに登録し、新 `bw-*` ターゲットへリダイレクト。WITH_BW チェックは新ターゲットで実行 |
| **廃止管理** | **冪等性** | 廃止予定ターゲットのマーカーファイル管理 | 旧ターゲット名のマーカーは作成しない。新ターゲット名でマーカーを作成し、エイリアス経由でも正しくスキップ判定 |
| **Bitwarden連携** | **冪等性** | `bw-unlock` の再実行 | `BW_SESSION` が有効な場合はスキップ（冪等性チェック）。`FORCE=1` で強制再アンロック |
| **Bitwarden連携** | **冪等性** | `setup-secrets` の再実行 | マーカーファイルで完了判定。`FORCE=1` または `clean-marker-setup-secrets` でマーカー削除後に再実行 |
| **冪等性** | **廃止管理** | `clean-markers` 実行時の廃止警告 | `clean-markers` は新ターゲット名で定義。旧名エイリアスはなし（管理ターゲットは廃止対象外） |
| **冪等性** | **Bitwarden連携** | マーカーファイルにシークレット情報 | **禁止**: マーカーファイルにシークレット値を含めない。完了タイムスタンプとバージョンのみ記録 |

### 組み合わせ動作仕様

#### シナリオ1: 廃止予定ターゲット + WITH_BW=1

```bash
# 旧ターゲット名で Bitwarden 連携を有効化して実行
make setup-secrets WITH_BW=1
```

| 条件 | 動作 |
|------|------|
| `MAKE_DEPRECATION_WARN=1` | 廃止警告を stderr に出力 → 新ターゲット `setup-config-secrets` にリダイレクト → WITH_BW チェック → Bitwarden 処理実行 |
| `MAKE_DEPRECATION_STRICT=1` | 廃止エラーで exit 1（Bitwarden 処理は実行されない） |
| デフォルト（警告なし） | サイレントに新ターゲットへリダイレクト → WITH_BW チェック → Bitwarden 処理実行 |

#### シナリオ2: bw-* ターゲット + FORCE=1

```bash
# 既存セッションを無視して強制アンロック
make bw-unlock WITH_BW=1 FORCE=1
```

| 条件 | 動作 |
|------|------|
| `FORCE=1` 設定 | `BW_SESSION` が有効でも再アンロックを実行 |
| `FORCE` 未設定 | `BW_SESSION` が有効な場合は既存セッションを再出力してスキップ |

#### シナリオ3: 廃止予定ターゲット + 冪等性スキップ

```bash
# 廃止予定ターゲットを再実行（既に完了済み）
make install-homebrew  # 旧名
```

| 条件 | 動作 |
|------|------|
| 新ターゲット `install-packages-homebrew` が完了済み | 旧名エイリアス経由でも `[SKIP]` メッセージを出力 |
| `FORCE=1` 設定 | 廃止警告（有効時）+ 新ターゲットで再インストール実行 |

#### シナリオ4: Bitwarden 状態異常 + 冪等性チェック

```bash
# WITH_BW=1 だが bw がロック状態
make setup-secrets WITH_BW=1
```

| 条件 | 動作 |
|------|------|
| マーカー未存在 + `bw status` = `locked` | エラー: `[ERROR] Bitwarden vault is locked.` を表示して exit 1。冪等性チェックより先に Bitwarden 状態チェックを実行 |
| マーカー存在 | `[SKIP]` を出力して exit 0。Bitwarden 状態チェックは**スキップ**（冪等性優先） |

### 処理順序の定義

各ターゲット実行時の処理順序を明確化:

```
1. 廃止予定チェック（deprecated-targets.mk）
   └─ 旧名→新名リダイレクト、警告出力
   
2. 冪等性チェック（idempotency.mk）
   └─ FORCE=1 の場合はスキップ
   └─ 満たされていれば [SKIP] で終了
   
3. 前提条件チェック
   └─ WITH_BW=1 の場合: jq 存在、bw 存在、bw 状態判定
   └─ 他の依存関係チェック
   
4. 本体処理実行
   └─ 成功時: マーカーファイル作成（MARKER_FILE メソッドの場合）
```

---

## 実装タスクチェックリスト

- [x] 1. エントリポイントとヘルプの確立
- [x] 1.1 デフォルト実行でヘルプを表示し、公開ターゲットだけを列挙する
  - `make` と `make help` で同一のヘルプが表示されるようにする
  - 公開/内部ターゲットの判定ルールを適用し、内部ターゲットはヘルプ表示から除外する
  - ヘルプ出力がカテゴリ別に整理され、主要な導線（セットアップ/インストール/チェック等）が一目で分かるようにする
  - `make` / `make help` 実行時にファイル作成やディレクトリ作成などの副作用が発生しないことを保証する
  - _Requirements: 1.1, 1.2_
  - **検証方法:**
    - `make` と `make help` を実行し、出力が同一であることを diff で確認
    - 内部ターゲット（`_`プレフィックス）がヘルプに表示されないことを grep で確認
    - `strace -e trace=file make help` を実行し、ファイル書き込み操作がないことを確認
  - **成功基準:**
    - `diff <(make 2>&1) <(make help 2>&1)` が差分なし
    - `make help | grep -E '^\s*_' | wc -l` が 0
    - `make` / `make help` 実行後にファイルシステムに変更がない（`MARKER_DIR` 未作成を含む）

- [x] 1.2 公開ターゲットのカテゴリと命名規則を要件に合わせて整備する
  - 要件で定義されたカテゴリ（システム設定、パッケージ、設定、管理、プリセット、段階的セットアップ等）に沿って公開ターゲットを揃える
  - 新規/整理後のターゲット名がハイフン区切りかつ動詞開始（`install-`, `setup-`, `update-`, `check-`, `clean-`）になるよう統一する
  - 内部ターゲットは先頭アンダースコアの命名に統一し、公開ターゲットと混在しないようにする
  - 既存の入口ターゲット（`quick`, `dev-setup`, `full`, `minimal` 等）がヘルプから見つけやすい配置になるよう調整する
  - _Requirements: 1.2, 1.4_
  - **検証方法:**
    - `make help` の出力を解析し、全公開ターゲットがカテゴリ見出しの下に配置されていることを確認
    - 全ターゲット名を抽出し、命名規則（ハイフン区切り、動詞開始）に準拠していることをパターンマッチで検証
    - `grep -E '^\.[A-Z]' mk/*.mk` で内部ターゲット定義を抽出し、`_` プレフィックスを確認
  - **成功基準:**
    - ヘルプ出力に「システム設定」「パッケージ」「設定」「管理」「プリセット」セクションが存在
    - 新規公開ターゲット名が全て `^(install|setup|update|check|clean|backup|export)-` にマッチ
    - 内部ターゲット名が全て `^_` で始まる

- [ ] 2. 既存ターゲット互換と廃止予定ターゲット管理
- [x] 2.1 (P) 短縮エイリアスを維持し、主要導線が壊れないようにする
  - 既存の短縮エイリアス（`i`, `s`, `c`, `u`, `m`, `h`, `claudecode`, `s1`〜`s5`, `ss`, `sg` など）が従来どおりに動作するようにする
  - 短縮エイリアスが「廃止予定の旧名エイリアス」と混在しないよう、責務を分離して管理できる状態にする
  - 短縮エイリアス経由でもヘルプ/公開ターゲット体系の期待される振る舞いが維持されることを確認する
  - _Requirements: 1.3_
  - **検証方法:**
    - 正規テストハーネス `bash tests/shortcuts.test.sh` を実行し、全14個の短縮エイリアス（i, s, c, u, m, h, claudecode, s1, s2, s3, s4, s5, ss, sg）の定義と対応関係を検証
    - `mk/shortcuts.mk` に短縮エイリアスのみ定義されていることを確認
    - `mk/deprecated-targets.mk` に旧名→新名エイリアスが定義されていることを確認
  - **成功基準:**
    - `bash tests/shortcuts.test.sh` が `[PASS]` で終了（exit 0）
    - テストが全14個のエイリアス（i, s, c, u, m, h, claudecode, s1, s2, s3, s4, s5, ss, sg）の存在と正しいマッピングを検証
    - `mk/shortcuts.mk` に `install-homebrew` 等の旧名エイリアスが含まれない

- [x] 2.2 (P) 旧ターゲット名→新ターゲット名の互換エイリアスを提供する
  - 旧ターゲット名が呼び出された場合に、新ターゲット名へ確実に誘導されるようにする
  - デフォルトでは廃止警告を出さず、後方互換の振る舞いを維持する
  - 旧名・新名いずれの経路でも失敗時に非0終了コードが返ることを担保する
  - _Requirements: 1.3, 2.1, 2.4_
  - **検証方法:**
    - 廃止予定マップの全ての旧ターゲット名を実行し、新ターゲットの動作と同一であることを確認
    - デフォルト（`MAKE_DEPRECATION_WARN` 未設定）で stderr に警告が出ないことを確認
    - 旧名経由で意図的に失敗させ（例: 存在しないパッケージ）、非0終了コードが返ることを確認
  - **成功基準:**
    - `make install-homebrew 2>&1` と `make install-packages-homebrew 2>&1` の出力が実質同一
    - デフォルト実行時に `[DEPRECATED]` 文字列が stderr に出力されない
    - 失敗時の終了コードが旧名・新名どちらも同じ非0値

- [x] 2.3 廃止ガイダンス出力とタイムラインポリシーを実装する
  - 廃止予定マップに「旧名/新名/廃止開始日/削除予定日/ステータス」を保持し、運用で更新できるようにする
  - `MAKE_DEPRECATION_WARN/QUIET/STRICT` に応じて、ガイダンスの出力有無・出力先（stderr）・終了コードを切り替える
  - warning/transition/removed の各フェーズで、要求されたメッセージ形式と終了コードを満たす
  - 最小警告期間などタイムラインポリシーの検証を行い、ポリシー違反は早期に検知して失敗させる
  - _Requirements: 2.2, 2.3, 2.4_
  - **検証方法:**
    - `DEPRECATED_TARGETS` 変数のフォーマットを解析し、5フィールド（旧名:新名:廃止日:削除日:ステータス）を確認
    - `MAKE_DEPRECATION_WARN=1 make install-homebrew 2>&1` で `[DEPRECATED]` が stderr に出力されることを確認
    - `MAKE_DEPRECATION_QUIET=1 MAKE_DEPRECATION_WARN=1 make install-homebrew 2>&1 | grep DEPRECATED` が空であることを確認
    - `MAKE_DEPRECATION_STRICT=1 make install-homebrew; echo $?` が 1 であることを確認
  - **成功基準:**
    - 廃止予定マップの各エントリが `OLD:NEW:YYYY-MM-DD:YYYY-MM-DD:STATUS` 形式
    - `MAKE_DEPRECATION_WARN=1` 時に stderr へ `[DEPRECATED]` メッセージが出力される
    - `MAKE_DEPRECATION_QUIET=1` 時に警告が抑制される
    - `MAKE_DEPRECATION_STRICT=1` 時に exit 1 で終了
    - 廃止開始日から削除予定日まで最低6ヶ月の間隔がある

---

### タスク2.1/2.2/2.3 責務マトリックス

| タスク | 責務 | 入力 | 出力 | 副作用 | 警告発信元 |
|--------|------|------|------|--------|-----------|
| **2.1 短縮エイリアス** | 永続的な短縮キー（`i`, `s`, `h`, `s1`〜`s5` 等）を提供 | ユーザーの短縮コマンド呼び出し | 正規ターゲットへの依存参照 | なし | **なし**（警告対象外・永続維持） |
| **2.2 レガシー→新名エイリアス** | 旧ターゲット名→新ターゲット名への透過的リダイレクト | 旧ターゲット名の呼び出し | 新ターゲットの実行結果 | なし（デフォルト）; `MAKE_DEPRECATION_WARN=1` で stderr 警告 | **2.3 が発信**（2.2 は呼び出しをトリガーするのみ） |
| **2.3 廃止ガイダンス/タイムライン** | 廃止予定マップ管理、警告出力、フェーズ判定、ポリシー検証 | 廃止予定マップ、環境変数（`MAKE_DEPRECATION_*`）、現在日付 | stderr への警告/エラー出力、終了コード制御 | `removed` フェーズ時は処理中断（exit 1） | **本タスクが唯一の警告発信元** |

#### 責務分離の原則

```
mk/shortcuts.mk          - 短縮エイリアスのみ（永続、廃止予定なし、警告なし）
                           例: i: install / h: help / s1: stage1

mk/deprecated-targets.mk - 旧名→新名エイリアス定義 + 廃止管理ロジック
                           例: install-homebrew: install-packages-homebrew
                           警告出力は本ファイル内の関数が担当
```

---

### 廃止予定マップ（権威的情報源）

**定義場所:** `mk/deprecated-targets.mk` 内の `DEPRECATED_TARGETS` 変数

**フィールド構造:**
```
旧名:新名:廃止開始日:削除予定日:ステータス
```

| フィールド | 説明 | 形式 | 例 |
|-----------|------|------|-----|
| **旧名** | 廃止対象のターゲット名 | ハイフン区切り文字列 | `install-homebrew` |
| **新名** | 移行先ターゲット名 | ハイフン区切り文字列 | `install-packages-homebrew` |
| **廃止開始日** | 警告フェーズ開始日 | ISO 8601 (YYYY-MM-DD) | `2026-02-01` |
| **削除予定日** | 完全削除予定日 | ISO 8601 (YYYY-MM-DD) | `2026-08-01` |
| **ステータス** | 現在のフェーズ | `warning` / `transition` / `removed` | `warning` |

---

### MAKE_DEPRECATION_* モード仕様

#### モード優先順位と動作マトリックス

| モード設定 | warning フェーズ | transition フェーズ | removed フェーズ |
|-----------|-----------------|-------------------|-----------------|
| デフォルト（全未設定） | サイレントリダイレクト、exit 0 | サイレント実行、exit 0 | **エラー出力、exit 1** |
| `MAKE_DEPRECATION_WARN=1` | 警告出力 + リダイレクト、exit 0 | 警告出力 + 実行、exit 0 | エラー出力、exit 1 |
| `MAKE_DEPRECATION_QUIET=1` | 警告抑制、exit 0 | 警告抑制、exit 0 | **エラー出力、exit 1**（QUIET 対象外） |
| `MAKE_DEPRECATION_STRICT=1` | **エラー出力、exit 1** | **エラー出力、exit 1** | エラー出力、exit 1 |
| `WARN=1` + `QUIET=1` | 警告抑制（QUIET 優先）、exit 0 | 警告抑制、exit 0 | エラー出力、exit 1 |
| `WARN=1` + `STRICT=1` | **エラー出力、exit 1**（STRICT 優先） | エラー出力、exit 1 | エラー出力、exit 1 |

#### stderr 出力メッセージフォーマット

**warning フェーズ（`MAKE_DEPRECATION_WARN=1` 時）:**
```
[DEPRECATED] Target '<旧名>' is deprecated and will be removed on <削除予定日>.
             Use '<新名>' instead.
             Migration: make <新名>
```

**transition フェーズ（`MAKE_DEPRECATION_WARN=1` 時）:**
```
[DEPRECATED] Target '<旧名>' is deprecated and scheduled for removal on <削除予定日>.
             This target will be removed in the next major version.
             Migrate now: make <新名>
             Proceeding with legacy behavior...
```

**removed フェーズ（常時）:**
```
[ERROR] Target '<旧名>' has been removed as of <削除予定日>.
        Use '<新名>' instead.
        Run: make <新名>
```

**STRICT モード時（warning/transition を即座にエラー化）:**
```
[DEPRECATED] Target '<旧名>' is deprecated and treated as error (MAKE_DEPRECATION_STRICT=1).
             Use '<新名>' instead.
             Migration: make <新名>
```

#### 終了コード一覧

| 状況 | 終了コード | 条件 |
|------|----------|------|
| 正常リダイレクト/実行完了 | `0` | warning/transition + デフォルトまたは WARN モード |
| 廃止エラー（removed） | `1` | removed フェーズ（常時） |
| STRICT モード違反 | `1` | STRICT=1 + warning または transition |
| ポリシー違反（最小警告期間） | `2` | 廃止開始日〜削除予定日が6ヶ月未満 |

---

### タイムラインポリシー検証テスト

#### テストケース一覧

| テストID | テスト内容 | 入力 | 期待結果 |
|----------|----------|------|---------|
| **TL-001** | 最小警告期間（6ヶ月）の遵守 | `廃止開始日=2026-02-01, 削除予定日=2026-08-01` | PASS（ちょうど6ヶ月） |
| **TL-002** | 最小警告期間違反の検出 | `廃止開始日=2026-02-01, 削除予定日=2026-05-01` | FAIL、exit 2、ポリシーエラー |
| **TL-003** | warning→transition 境界 | `現在日=削除予定日-30日` | ステータスが `transition` に変化 |
| **TL-004** | transition→removed 境界 | `現在日=削除予定日` | ステータスが `removed` に変化、exit 1 |
| **TL-005** | 未来の廃止開始日 | `廃止開始日 > 現在日` | 警告なし、通常動作 |

#### CLI 統合テスト例

```bash
# TL-001: 正常ケース - 最小警告期間を満たす
$ make validate-deprecation-policy TARGET=install-homebrew
[OK] install-homebrew: 2026-02-01 → 2026-08-01 (182 days, >= 180 required)

# TL-002: 違反ケース - 最小警告期間未満
$ make validate-deprecation-policy TARGET=test-invalid-target
[ERROR] test-invalid-target: 2026-02-01 → 2026-05-01 (89 days, < 180 required)
        Minimum warning period is 6 months (180 days).
$ echo $?
2

# TL-003: warning フェーズでの動作
$ MAKE_DEPRECATION_WARN=1 make install-homebrew
[DEPRECATED] Target 'install-homebrew' is deprecated and will be removed on 2026-08-01.
             Use 'install-packages-homebrew' instead.
             Migration: make install-packages-homebrew
# (新ターゲットの処理が実行される)
$ echo $?
0

# TL-004: removed フェーズでの動作（削除予定日以降）
$ make install-removed-target
[ERROR] Target 'install-removed-target' has been removed as of 2026-08-01.
        Use 'install-packages-removed-target' instead.
        Run: make install-packages-removed-target
$ echo $?
1

# TL-005: STRICT モードでの動作
$ MAKE_DEPRECATION_STRICT=1 make install-homebrew
[DEPRECATED] Target 'install-homebrew' is deprecated and treated as error (MAKE_DEPRECATION_STRICT=1).
             Use 'install-packages-homebrew' instead.
             Migration: make install-packages-homebrew
$ echo $?
1
```

#### 単体テスト（make test-deprecation-policy）

**注意:** 日付パース処理は GNU/Linux と macOS/BSD の両方で動作するクロスプラットフォーム実装を使用。

```makefile
# ============================================================
# クロスプラットフォーム日付変換ヘルパー
# GNU date (Linux, gdate on macOS) と BSD date (macOS) の両方に対応
# ============================================================
# 使用方法: $(call date_to_epoch,YYYY-MM-DD)
# 戻り値: Unix epoch 秒、または失敗時は 0
define date_to_epoch
$(shell \
	if command -v gdate >/dev/null 2>&1; then \
		gdate -d "$(1)" +%s 2>/dev/null || echo 0; \
	elif date -d "$(1)" +%s >/dev/null 2>&1; then \
		date -d "$(1)" +%s; \
	elif date -j -f "%Y-%m-%d" "$(1)" +%s >/dev/null 2>&1; then \
		date -j -f "%Y-%m-%d" "$(1)" +%s; \
	else \
		echo 0; \
	fi \
)
endef

.PHONY: test-deprecation-policy
test-deprecation-policy: ## 廃止タイムラインポリシーの検証テスト
	@echo "=== Deprecation Timeline Policy Tests ==="
	@# クロスプラットフォーム日付変換関数（シェル内で定義）
	@date_to_epoch() { \
		if command -v gdate >/dev/null 2>&1; then \
			gdate -d "$$1" +%s 2>/dev/null || echo 0; \
		elif date -d "$$1" +%s >/dev/null 2>&1; then \
			date -d "$$1" +%s; \
		elif date -j -f "%Y-%m-%d" "$$1" +%s >/dev/null 2>&1; then \
			date -j -f "%Y-%m-%d" "$$1" +%s; \
		else \
			echo 0; \
		fi; \
	}; \
	echo "[TEST] TL-001: Minimum warning period validation..."; \
	for entry in $(DEPRECATED_TARGETS); do \
		old=$$(echo "$$entry" | cut -d: -f1); \
		dep_date=$$(echo "$$entry" | cut -d: -f3); \
		rem_date=$$(echo "$$entry" | cut -d: -f4); \
		dep_epoch=$$(date_to_epoch "$$dep_date"); \
		rem_epoch=$$(date_to_epoch "$$rem_date"); \
		if [ "$$dep_epoch" = "0" ] || [ "$$rem_epoch" = "0" ]; then \
			echo "[FAIL] $$old: Failed to parse deprecation dates (dep=$$dep_date, rem=$$rem_date)"; \
			echo "       Install GNU coreutils: brew install coreutils (macOS)"; \
			exit 2; \
		fi; \
		diff_days=$$(( (rem_epoch - dep_epoch) / 86400 )); \
		if [ $$diff_days -lt 180 ]; then \
			echo "[FAIL] $$old: $$diff_days days < 180 required"; \
			exit 2; \
		else \
			echo "[PASS] $$old: $$diff_days days >= 180 required"; \
		fi; \
	done
	@echo ""
	@# TL-002: 日付フォーマット検証
	@echo "[TEST] TL-002: Date format validation (ISO 8601)..."
	@for entry in $(DEPRECATED_TARGETS); do \
		dep_date=$$(echo "$$entry" | cut -d: -f3); \
		rem_date=$$(echo "$$entry" | cut -d: -f4); \
		if ! echo "$$dep_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$$'; then \
			echo "[FAIL] Invalid deprecation date format: $$dep_date"; \
			exit 2; \
		fi; \
		if ! echo "$$rem_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$$'; then \
			echo "[FAIL] Invalid removal date format: $$rem_date"; \
			exit 2; \
		fi; \
	done
	@echo "[PASS] All dates in ISO 8601 format"
	@echo ""
	@echo "=== All Policy Tests Passed ==="
```

---

- [ ] 3. Bitwarden 連携（WITH_BW オプトイン）
- [x] 3.1 WITH_BW オプトインメカニズムの基盤を確立する
  - `WITH_BW=1` の場合のみ Bitwarden 連携を有効化し、未設定/`WITH_BW=0` は完全にスキップする共通関数 `bw_require_opt_in` を実装する
  - 汎用ターゲットは Bitwarden 連携をスキップして正常終了し、`bw-*` ターゲットは案内を出して exit 0 で終了する動作を定義する
  - 環境変数としての設定と Make 引数としての指定の両方で有効化でき、CI/ローカルで同一の挙動になるようにする
  - 既存のレガシースクリプトが `WITH_BW` を認識しない場合でも、破壊的変更を起こさず従来動作を維持する
  - **スコープ:** 本タスクは基盤メカニズムの確立に限定する。`bw-status` と `bw-unlock` で実証し、他の既存ターゲット（`setup-secrets` 等）への統合はタスク3.4で実施する
  - _Requirements: 2.5, 2.6, 2.7, 2.8, 3.1_
  - **検証方法:**
    - `make bw-status` と `make bw-status WITH_BW=1` の動作差異を確認
    - `export WITH_BW=1 && make bw-status` と `make bw-status WITH_BW=1` が同一動作であることを確認
    - `make install` が WITH_BW 未設定時に Bitwarden 関連エラーなく完了することを確認（後方互換性）
    - `make bw-unlock` が WITH_BW 未設定時に適切な警告メッセージで終了することを確認
  - **成功基準:**
    - `make bw-unlock` (WITH_BW 未設定) → stderr に `[WARN] Bitwarden integration is disabled.` が出力、exit 0
    - `make bw-unlock WITH_BW=1` (bw 未導入時) → stderr に `[ERROR] Bitwarden CLI (bw) is not installed.` が出力、exit 1
    - 環境変数 `WITH_BW=1` と引数 `WITH_BW=1` の動作が完全同一
    - レガシーターゲット（`make install`）は WITH_BW 未設定時も正常終了（Bitwarden 連携部分は未実装でも可）

- [x] 3.2 Bitwarden 状態判定とエラーハンドリングを整備し、秘匿情報を出力しない
  - Bitwarden CLI の状態を判定し、操作可能/不可の理由（未導入、未ログイン、ロック等）を人間可読に案内できるようにする
  - `WITH_BW=1` で必要な前提（例: `bw`, `jq`）が不足している場合は、具体的な解決手順を示して失敗（exit 1）する
  - `jq` が利用できない環境では、最小限の状態判定をフォールバック（grep 等）で行えるようにする
  - どの失敗モードでも、シークレット値やセッションキーが stdout/stderr/ログに出ないよう出力契約を統一する
  - _Requirements: 3.2, 3.3, 3.7_
  - **検証方法:**
    - `make bw-status WITH_BW=1` を各状態（未導入/未ログイン/ロック/アンロック）で実行し、正確な状態表示を確認
    - jq 未導入環境で `make bw-status WITH_BW=1` を実行し、エラーメッセージに jq インストール手順が含まれることを確認
    - 全 Bitwarden ターゲットの stdout/stderr 出力をキャプチャし、`BW_SESSION` 値が含まれないことを grep で確認
  - **成功基準:**
    - `make bw-status WITH_BW=1` が以下を正しく表示:
      - bw 未導入時: `Status: NOT INSTALLED`
      - 未ログイン時: `Vault Status: unauthenticated`
      - ロック時: `Vault Status: locked`
      - アンロック時: `Vault Status: unlocked` + `Logged in as: <email>`
    - jq 未導入時: `[ERROR] jq is required for Bitwarden integration.` が表示
    - `make bw-unlock WITH_BW=1 2>&1 | grep -E 'BW_SESSION=[^"]'` が空（セッションキー漏洩なし）

- [x] 3.3 `bw-unlock` を eval パターンで提供し、BW_SESSION を永続化しない
  - 成功時は `export BW_SESSION="..."` 形式のみを stdout に出力し、`eval` で設定できるようにする
  - `BW_SESSION` が既に設定済みかつ有効な場合は、再アンロックせず既存セッションを再出力する
  - `BW_PASSWORD` が設定されている場合は、非対話的にアンロックできるようにする
  - 失敗時は stderr のみで案内し、要件どおりの終了コード（`WITH_BW` 未設定時は警告のみ）を返す
  - _Requirements: 3.4, 3.5, 3.6, 3.8_
  - **検証方法:**
    - `make bw-unlock WITH_BW=1` の stdout が `export BW_SESSION="..."` 形式のみであることを確認
    - `eval $(make bw-unlock WITH_BW=1) && echo $BW_SESSION` でセッションが設定されることを確認
    - 既存 `BW_SESSION` が有効な状態で `make bw-unlock WITH_BW=1` を実行し、再アンロックが発生しないことを確認
    - `BW_PASSWORD=xxx make bw-unlock WITH_BW=1` が非対話的に動作することを確認
  - **成功基準:**
    - stdout 出力が `^export BW_SESSION="[A-Za-z0-9+/=]+"$` パターンにマッチ
    - `eval $(make bw-unlock WITH_BW=1)` 後に `bw status | jq -r '.status'` が `unlocked` を返す
    - 有効な `BW_SESSION` 設定時、`bw unlock` コマンドが呼び出されない（再アンロックスキップ）
    - 失敗時の stderr に `[ERROR]` が含まれ、stdout が空

- [x] 3.4 シークレット取得を自動化フローに接続し、既存ターゲットに統合する
  - 指定アイテム名からシークレットを取得し、必要なコマンド実行へ渡せるようにする
  - 未ログイン/ロック/未導入/ネットワークエラー/未発見の各シナリオで、期待されるメッセージと終了コードを満たす
  - **タスク3.1で確立した `bw_require_opt_in` 基盤を、`setup-secrets` など既存の関連ターゲットに統合する**
  - 汎用ターゲット（`install`, `setup` 等）は `WITH_BW` 未設定時に Bitwarden 連携部分を安全にスキップし、Bitwarden 専用ターゲット（`bw-*`）は明確に警告を出す
  - _Requirements: 3.1, 3.2, 3.3_
  - **検証方法:**
    - `make bw-get-item-test-secret WITH_BW=1` を実行し、シークレット値が stdout に出力されることを確認
    - 各エラーシナリオ（未ログイン/ロック/未導入/未発見）で適切なエラーメッセージと終了コードを確認
    - シークレット取得成功時、取得値が環境変数として後続処理で利用可能であることを確認
    - `make setup-secrets` が WITH_BW 未設定時に警告のみで終了することを確認
    - `make setup-secrets WITH_BW=1` が Bitwarden からシークレットを取得して設定することを確認
  - **成功基準:**
    - シナリオ1（bw 未導入）: `[ERROR] Bitwarden CLI (bw) is not installed.` + exit 1
    - シナリオ2（未ログイン）: `[ERROR] Bitwarden CLI is not logged in.` + exit 1
    - シナリオ3（ロック）: `[ERROR] Bitwarden vault is locked.` + exit 1
    - シナリオ4（未発見）: `[ERROR] Secret not found: <item-name>` + exit 1
    - 正常取得時: パスワードまたはノートの値のみが stdout に出力
    - `setup-secrets` など既存ターゲットが `bw_require_opt_in` を使用して WITH_BW フラグに応答する

- [ ] 4. 冪等性基盤と安全な再実行
- [x] 4.1 (P) 冪等性検出メソッドを共通化し、パース時副作用ゼロを保証する
  - 許可された冪等性検出メソッド（ファイル存在/バージョン/マーカー/コマンド成功）を共通の仕組みとして提供する
  - マーカーファイルを規定ディレクトリに作成し、権限や内容フォーマットの要件を満たす
  - バージョン比較、シンボリックリンク一致、コマンド存在などの標準パターンを提供する
  - `make` / `make help` の実行時にファイルシステム変更が発生しない（パース時副作用ゼロ）ことを担保する
  - _Requirements: 4.1, 4.3, 4.4, 4.5_
  - **検証方法:**
    - `mk/idempotency.mk` に `create_marker`, `check_marker`, `check_min_version`, `check_symlink`, `check_command` 関数が定義されていることを確認
    - マーカーファイルのフォーマットが要件（Target, Completed, Version）を満たすことを確認
    - クリーンな環境で `make help` を実行し、`MARKER_DIR` が作成されないことを確認
    - `$(shell mkdir -p ...)` がパース時に実行されないことをコードレビューで確認
  - **成功基準:**
    - `create_marker` 呼び出し時にマーカーファイルが `${XDG_STATE_HOME:-$HOME/.local/state}/dots/.done-<target>` に作成される
    - マーカーファイル内容が `# Target: <name>`, `# Completed: <timestamp>`, `# Version: <ver>` を含む
    - マーカーディレクトリの権限が `700`
    - `make help` 実行前後で `ls ~/.local/state/dots/` の結果が変化しない

- [x] 4.2 公開ターゲットごとに冪等性検出を宣言し、充足時は安全にスキップできるようにする
  - 公開ターゲットが利用する冪等性検出メソッドを明示し、要件の宣言テーブルに整合するよう揃える
  - 依存が未満たしの場合は不足を報告して失敗し、充足している場合は再インストールせず完了できるようにする
  - スキップ時は `[SKIP] <target> is already completed.` 形式で stdout に表示する
  - _Requirements: 4.2, 4.7_
  - **検証方法:**
    - 主要公開ターゲット（`install-packages-homebrew`, `setup-config-vim` 等）を2回連続実行し、2回目で `[SKIP]` が出力されることを確認
    - 依存未満たし時（例: brew 未導入で `install-packages-apps`）に適切なエラーメッセージが出ることを確認
    - 各ターゲットの冪等性メソッドが requirements.md §4.2 のテーブルと一致することを確認
  - **成功基準:**
    - `make install-packages-homebrew && make install-packages-homebrew` の2回目で `[SKIP] install-packages-homebrew is already completed.` が出力
    - 依存未満たし時に `[ERROR]` または `[CHECK]` メッセージで不足内容が表示される
    - 全公開ターゲットが FILE_EXISTS / VERSION_CHECK / MARKER_FILE / COMMAND_CHECK のいずれかを使用

- [x] 4.3 マーカーのクリーンアップと強制再実行の導線を提供する
  - マーカーファイルの全削除/個別削除を行える管理ターゲットを提供する
  - 現在の冪等性状態を一覧化するターゲットを提供し、問題切り分けに使えるようにする
  - `FORCE=1` 設定時は冪等性チェックをスキップして再実行できるようにする
  - _Requirements: 4.6, 4.7_
  - **検証方法:**
    - `make clean-markers` 実行後に `MARKER_DIR` 内の `.done-*` ファイルが全削除されることを確認
    - `make clean-marker-setup-system` 実行後に該当マーカーのみ削除されることを確認
    - `make check-idempotency` で現在のマーカー状態とパッケージ状態が一覧表示されることを確認
    - `make setup-system FORCE=1` が既存マーカーを無視して再実行されることを確認
  - **成功基準:**
    - `make clean-markers` 後: `ls ~/.local/state/dots/.done-* 2>/dev/null | wc -l` が 0
    - `make clean-marker-setup-system` 後: `.done-setup-system` のみ削除、他のマーカーは残存
    - `make check-idempotency` 出力に「Marker Files」「Package Installation Status」「Config Symlinks Status」セクションが含まれる
    - `FORCE=1` 時に `[FORCE] Re-running <target>.` メッセージが表示される

- [ ] 5. Devcontainer 内のテスト環境
- [x] 5.1 (P) Devcontainer を用意し、コンテナ内で Make ターゲットのテストが完結するようにする
  - ベースイメージと必要な依存関係を揃え、コンテナ内で Make ターゲットが実行できる状態にする
  - Bitwarden CLI を指定バージョン以上でインストールできるようにする
  - ホスト依存がある操作は、コンテナ内での代替または前提条件チェックにより明示する
  - _Requirements: 5.1, 5.2_
  - **検証方法:**
    - `.devcontainer/Dockerfile` が存在し、ビルド可能であることを確認
    - コンテナ内で `make --version`, `bw --version`, `jq --version` が実行可能であることを確認
    - コンテナ内で `make help` が正常に動作することを確認
  - **成功基準:**
    - `docker build -t dots-devcontainer .devcontainer/` が成功
    - コンテナ内: `make --version` が 4.3 以上を返す
    - コンテナ内: `bw --version` が 2024.9.0 以上を返す
    - コンテナ内: `jq --version` が 1.6 以上を返す
    - コンテナ内: `make help` が exit 0 で終了し、ヘルプが表示される


- [x] 5.2 クレデンシャル転送と起動時ブートストラップを実装する
  - `BW_SESSION` と `WITH_BW` をホストからコンテナへ安全に転送できるようにする
  - コンテナ作成時に依存関係検証とテストセットアップを自動実行し、`WITH_BW=1` の場合のみ疎通確認を実施する
  - _Requirements: 5.3, 5.4_
  - **検証方法:**
    - `.devcontainer/devcontainer.json` に `remoteEnv` で `BW_SESSION` と `WITH_BW` が定義されていることを確認
    - `postCreateCommand` が依存関係チェック（`make check-deps`）を実行することを確認
    - ホストで `export BW_SESSION=xxx` 後にコンテナを起動し、コンテナ内で `echo $BW_SESSION` が同じ値を返すことを確認
  - **成功基準:**
    - `devcontainer.json` の `remoteEnv` に `"BW_SESSION": "${localEnv:BW_SESSION}"` が含まれる
    - `postCreateCommand` に `make check-deps` または同等のコマンドが含まれる
    - ホスト環境変数がコンテナ内に正しく転送される
    - `WITH_BW=1` 時のみ `bw-status` チェックが実行される

- [x] 5.3 モック/統合テストを Make ターゲットとして提供し、CI/ローカル双方で検証できるようにする
  - 認証不要のモックテストで Bitwarden 連携の主要分岐を再現し、失敗モードの挙動を検証できるようにする
  - `BW_SESSION` 必須の統合テストを用意し、未設定時は明確に失敗させる
  - `make test` で冪等性/ヘルプ/エイリアスと Bitwarden 連携の検証をまとめて実行できるようにする
  - _Requirements: 5.5_
  - **検証方法:**
    - `make test-bw-mock` が認証なしで実行可能であることを確認
    - `make test-bw-integration` が `BW_SESSION` 未設定時にエラー終了することを確認
    - `make test` が `test-unit` と `test-bw-mock` を順次実行することを確認
    - `.devcontainer/mocks/bw` が存在し、実行可能であることを確認
  - **成功基準:**
    - `make test-bw-mock` が exit 0 で終了（モック bw を使用）
    - `make test-bw-integration` (BW_SESSION 未設定時) が `[ERROR] BW_SESSION is required` で exit 1
    - `make test` が `test-unit` と `test-bw-mock` の両方を実行
    - モック bw スクリプトが各状態（unlocked/locked/unauthenticated）を再現可能
