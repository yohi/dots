#!/usr/bin/env zsh

# Cursor IDE をカレントディレクトリで起動する関数
# 使用方法: cursor
# または: cursor [ディレクトリパス]

function cursor() {
    # 引数が指定されている場合はそのディレクトリで起動
    if [ $# -gt 0 ]; then
        local target_dir="$1"
        if [ -d "$target_dir" ]; then
            echo "Opening Cursor IDE in directory: $target_dir"
            /home/y_ohi/.local/bin/cursor "$target_dir"
        else
            echo "Error: Directory '$target_dir' does not exist"
            return 1
        fi
    else
        # 引数がない場合はカレントディレクトリで起動
        echo "Opening Cursor IDE in current directory: $(pwd)"
        /home/y_ohi/.local/bin/cursor .
    fi
}
