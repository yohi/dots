# LazyGit Gemini CLI Conventional Commit Generator

LazyGit の Files コンテキストで Ctrl+a を押すと、Gemini CLI で Conventional Commits v1.0.0 準拠のコミットメッセージ案を生成し、確認のうえ `git commit -e -F` を起動するためのスクリプトと設定例です。

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
    description: "Gemini: generate Conventional Commit (review + edit before commit)"
    loadingText: "Generating commit message with Gemini..."
    prompts:
      - type: "input"
        title: "Context hint (optional)"
        key: "Hint"
        initialValue: ""
    command: "COMMIT_HINT={{.Form.Hint | quote}} lg-gemini-commit"
    output: "terminal"
    subprocess: true
```

## 使い方

1. LazyGit で変更をステージします。
2. Files コンテキストで Ctrl+a を押します。
3. 必要ならヒントを入力（任意）します。
4. 生成されたメッセージが端末に表示されます。
5. `Proceed? (y/N)` で `y` を選択するとエディタが開きます。
6. エディタで最終確認・修正して保存 → commit。

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
