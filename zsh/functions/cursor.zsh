#!/usr/bin/env zsh

# Cursor IDE をカレントディレクトリで起動する関数
# 使用方法: cursor
# または: cursor [ディレクトリパス]

function cursor() {
    local cursor_bin="${CURSOR_BIN:-$(command -v cursor 2>/dev/null)}"
    if [[ -z "${cursor_bin}" ]]; then
        echo "エラー: Cursor 実行ファイルが見つかりません（PATH または CURSOR_BIN を確認してください）"
        return 127
    fi

    if [[ $# -gt 0 ]]; then
        local target_dir="$1"
        if [[ -d "$target_dir" ]]; then
            echo "Cursor を次のディレクトリで起動します: $target_dir"
            "${cursor_bin}" -- "$target_dir"
        else
            echo "エラー: ディレクトリが存在しません: $target_dir"
            return 1
        fi
    else
        echo "Cursor をカレントディレクトリで起動します: $(pwd)"
        "${cursor_bin}" -- .
    fi
}
