#!/bin/bash
# 定期クリーンアップスクリプト
# 使用方法: ./auto-cleanup.sh [--dry-run] [--force]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# オプション処理
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            echo "使用方法: $0 [--dry-run] [--force]"
            echo "  --dry-run: 実際の削除を行わず、確認のみ"
            echo "  --force:   確認なしで実行"
            exit 1
            ;;
    esac
done

# 色コード定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 Dotfiles 自動クリーンアップ${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 対象ディレクトリ: $DOTFILES_DIR"
echo "🔄 モード: $([ "$DRY_RUN" == "true" ] && echo "DRY-RUN (確認のみ)" || echo "実行モード")"
echo "📊 開始時刻: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

cd "$DOTFILES_DIR"

# クリーンアップカウンタ
TOTAL_CLEANED=0
FILES_REMOVED=0
DIRS_REMOVED=0
SIZE_SAVED=0

# 実行関数
execute_cleanup() {
    local action="$1"
    local target="$2"
    local description="$3"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $action: $target ($description)"
    else
        if [[ "$FORCE" == "true" ]] || read -p "$(echo -e "${GREEN}実行しますか?${NC} $action: $target ($description) [y/N]: ")" -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            eval "$action \"$target\""
            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}✅ 完了:${NC} $target"
                ((TOTAL_CLEANED++))
            else
                echo -e "${RED}❌ 失敗:${NC} $target"
            fi
        else
            echo -e "\n${YELLOW}⏭️  スキップ:${NC} $target"
        fi
    fi
}

echo -e "${BLUE}🔍 一時ファイル・キャッシュファイルの検出${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 一時ファイルの検出と削除
TEMP_FILES=(
    "*.tmp"
    "*.temp"
    "*.cache"
    "*.bak"
    "*~"
    ".DS_Store"
    "Thumbs.db"
    "*.swp"
    "*.swo"
)

echo "🗂️  一時ファイル検索:"
for pattern in "${TEMP_FILES[@]}"; do
    found_files=$(find . -name "$pattern" -type f ! -path "./.git/*" ! -path "./scripts/monitoring/*" 2>/dev/null)
    if [[ ! -z "$found_files" ]]; then
        count=$(echo "$found_files" | wc -l)
        size=$(echo "$found_files" | xargs du -ch 2>/dev/null | tail -1 | cut -f1)
        echo "  📄 $pattern: $count ファイル ($size)"

        echo "$found_files" | while read file; do
            if [[ -f "$file" ]]; then
                execute_cleanup "rm -f" "$file" "一時ファイル"
                ((FILES_REMOVED++))
            fi
        done
    fi
done

# 2. 空ディレクトリの検出と削除
echo ""
echo -e "${BLUE}📁 空ディレクトリの検出${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

EMPTY_DIRS=$(find . -type d -empty ! -path "./.git/*" 2>/dev/null)
if [[ ! -z "$EMPTY_DIRS" ]]; then
    echo "🗂️  空ディレクトリ:"
    echo "$EMPTY_DIRS" | while read dir; do
        if [[ -d "$dir" && ! "$dir" == "." ]]; then
            execute_cleanup "rmdir" "$dir" "空ディレクトリ"
            ((DIRS_REMOVED++))
        fi
    done
else
    echo "✨ 空ディレクトリは見つかりませんでした"
fi

# 3. 重複ファイルの検出
echo ""
echo -e "${BLUE}🔍 重複ファイルの検出${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 同名ファイルの検出 (拡張子違い)
echo "🔍 類似ファイル検索:"
find . -type f ! -path "./.git/*" ! -name "*.backup.*" | while read file; do
    basename=$(basename "$file")
    dirname=$(dirname "$file")
    name_without_ext="${basename%.*}"

    # 同じ名前で異なる拡張子のファイルをチェック
    similar_files=$(find "$dirname" -maxdepth 1 -name "${name_without_ext}.*" -type f | wc -l)
    if [[ $similar_files -gt 1 ]]; then
        echo "  🔄 類似ファイル群: $dirname/$name_without_ext.*"
        find "$dirname" -maxdepth 1 -name "${name_without_ext}.*" -type f | sort
    fi
done | sort | uniq

# 4. 古いバックアップファイルの検出
echo ""
echo -e "${BLUE}🗃️  古いバックアップファイルの検出${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 30日以上古いバックアップファイル
OLD_BACKUPS=$(find . -name "*.backup.*" -type f -mtime +30 ! -path "./.git/*" 2>/dev/null)
if [[ ! -z "$OLD_BACKUPS" ]]; then
    echo "🗂️  30日以上前のバックアップ:"
    echo "$OLD_BACKUPS" | while read backup; do
        age=$(stat -c %Y "$backup")
        current=$(date +%s)
        days=$(( (current - age) / 86400 ))
        size=$(du -h "$backup" | cut -f1)
        execute_cleanup "rm -f" "$backup" "$days日前のバックアップ ($size)"
        ((FILES_REMOVED++))
    done
else
    echo "✨ 古いバックアップファイルは見つかりませんでした"
fi

# 5. 大きなファイルの検出
echo ""
echo -e "${BLUE}📊 大きなファイルの検出${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1MB以上のファイル
LARGE_FILES=$(find . -type f -size +1M ! -path "./.git/*" 2>/dev/null)
if [[ ! -z "$LARGE_FILES" ]]; then
    echo "📊 1MB以上のファイル:"
    echo "$LARGE_FILES" | while read large_file; do
        size=$(du -h "$large_file" | cut -f1)
        echo "  📄 $large_file: $size"
    done
    echo "💡 必要に応じて手動で確認・削除してください"
else
    echo "✨ 大きなファイルは見つかりませんでした"
fi

# 6. Git管理外ファイルの確認
echo ""
echo -e "${BLUE}📋 Git管理外ファイルの確認${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

UNTRACKED=$(git status --porcelain 2>/dev/null | grep "^??" | cut -c4-)
if [[ ! -z "$UNTRACKED" ]]; then
    echo "📄 Git管理外ファイル:"
    echo "$UNTRACKED" | head -10 | while read untracked; do
        echo "  📄 $untracked"
    done

    count=$(echo "$UNTRACKED" | wc -l)
    if [[ $count -gt 10 ]]; then
        echo "  ... および $((count - 10)) 個のファイル"
    fi
    echo "💡 必要に応じて git add または .gitignore に追加してください"
else
    echo "✨ すべてのファイルがGitで管理されています"
fi

# 7. 最終サマリー
echo ""
echo -e "${BLUE}📊 クリーンアップサマリー${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "🔍 DRY-RUN完了 - 実際の削除は行われませんでした"
else
    echo "✅ 削除されたファイル: $FILES_REMOVED 個"
    echo "✅ 削除されたディレクトリ: $DIRS_REMOVED 個"
    echo "📊 総操作数: $TOTAL_CLEANED 件"
fi

echo "⏰ 処理時間: $(date '+%Y-%m-%d %H:%M:%S')"

# 改善提案
echo ""
echo -e "${BLUE}💡 メンテナンス提案${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 定期実行の推奨:"
echo "  • 週1回の自動クリーンアップ実行"
echo "  • 月1回のフルスキャン"
echo "  • プロジェクト更新時のメンテナンス"

echo ""
echo "📝 ログ保存: $SCRIPT_DIR/cleanup-$(date +%Y%m%d_%H%M%S).log"
echo "🏁 クリーンアップ完了"


