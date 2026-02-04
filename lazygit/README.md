# LazyGit Gemini CLI Conventional Commit Generator

LazyGit の Files コンテキストで Ctrl+a を押すと、Gemini CLI で Conventional Commits v1.0.0 準拠のコミットメッセージ案を生成し、LazyGit 内のメニューで確認して `git commit -m` を実行するためのスクリプトと設定例です。

## 導入手順

### 1. Gemini CLI を用意

`gemini` コマンドが実行できる状態にしてください。

```bash
gemini --version
```

> Gemini CLI のインストール手順は公式ドキュメントに従ってください。

### 2. スクリプトを配置

```bash
chmod +x bin/lg-gemini-commit
```

PATH に通すか、LazyGit の設定で絶対パスを指定してください。

### 3. LazyGit に設定を追加

`examples/lazygit-config-snippet.yml` の内容を `~/.config/lazygit/config.yml` に追記します。

```yaml
customCommands:
  - key: "<c-a>"
    context: "files"
    description: "Gemini: generate Conventional Commit (menu)"
    loadingText: "Generating commit message with Gemini..."
    prompts:
      - type: "menuFromCommand"
        title: "Select commit message"
        key: "SelectedMsg"
        command: "sh -c 'COMMIT_MODE=menu lg-gemini-commit'"
        filter: "^(?P<msg>.+\\S.*)$"
        valueFormat: "{{ .msg }}"
        labelFormat: "{{ .msg }}"
    command: "git commit -m {{.Form.SelectedMsg | quote}}"
    output: "none"
```

## 使い方

1. LazyGit で変更をステージします。
2. Files コンテキストで Ctrl+a を押します。
3. 生成されたメッセージのメニューが表示されます。
4. 内容がOKなら選択して commit します。

## 動作確認（手動）

1. staged なし → 何もしない/メッセージ表示で終了
2. 小さな修正（1ファイル） → `fix:` または `feat:` が妥当に生成される
3. 複数ディレクトリ変更 → scope が妥当（または scope 省略でもOK）
4. 破壊的変更っぽい diff → `!` と `BREAKING CHANGE:` が付く（理想）
5. 生成文が規約違反 → エラーで止まる（commit しない）

## 環境変数

| 変数名 | 既定値 | 内容 |
| --- | --- | --- |
| `MAX_DIFF_LINES` | `800` | Gemini に渡す staged diff の最大行数 |
| `COMMIT_MSG_FILE` | `.git/.gemini_commitmsg` | 一時コミットメッセージの保存先 |
| `GEMINI_MODEL` | `gemini-3-flash-preview` | Gemini CLI のモデル指定（存在しない場合はフォールバック） |
| `SMALL_DIFF_MODEL` | `gemini-2.5-flash-lite` | diff が小さい場合に使うモデル |
| `MODEL_SWITCH_LINES` | `200` | diff 行数がこの値以下なら `SMALL_DIFF_MODEL` を使用 |
| `FALLBACK_MODEL` | `gemini-1.5-flash` | モデルが見つからない場合のフォールバック |
| `TIMEOUT_SECONDS` | `30` | Gemini CLI のタイムアウト秒数（`timeout` がある場合のみ） |

## トラブルシュート

### gemini が見つからない

```bash
which gemini
```

PATH に Gemini CLI が入っているか確認してください。

### diff が大きすぎる

`MAX_DIFF_LINES` を小さくすると安定します。

```bash
MAX_DIFF_LINES=400 lazygit
```

### 生成文が規約違反で止まる

Gemini の出力が以下の正規表現に一致しない場合は commit を起動しません。

```
^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?(!)?: .+
```

ステージング内容を整理するか、もう一度 Ctrl+a を実行してください。

### LazyGit の customCommands で set を使うと失敗する

`command` はシェルコマンドとして実行されるため、`set -eu` を書くと `set` を実行ファイルとして解釈して失敗します。`set` はスクリプト内に書いてください。
