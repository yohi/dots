#!/bin/bash
# Makefile実行時間プロファイラー
# 使用方法: ./makefile-profiler.sh [ターゲット名]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TARGET=${1:-"help"}
LOG_FILE="$SCRIPT_DIR/makefile-performance.log"

echo "🔧 Makefile パフォーマンス分析"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 対象ディレクトリ: $DOTFILES_DIR"
echo "🎯 実行ターゲット: $TARGET"
echo "📊 測定開始: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

cd "$DOTFILES_DIR"

# Make実行時間を測定
echo "⏱️  実行中: make $TARGET"
start_time=$(date +%s.%3N)

# 実際のmake実行（出力をキャプチャ）
make_output=$(make $TARGET 2>&1)
make_exit_code=$?

end_time=$(date +%s.%3N)

# 実行時間計算（ミリ秒）
execution_time=$(echo "($end_time - $start_time) * 1000" | bc)

echo ""
echo "📊 実行結果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "⏱️  実行時間: %.1fms\n" $execution_time
echo "📤 終了コード: $make_exit_code"

# パフォーマンス評価
if (( $(echo "$execution_time < 100" | bc -l) )); then
    echo "🎉 評価: 高速 (100ms未満)"
elif (( $(echo "$execution_time < 500" | bc -l) )); then
    echo "✅ 評価: 良好 (100-500ms)"
elif (( $(echo "$execution_time < 1000" | bc -l) )); then
    echo "⚠️  評価: 普通 (500ms-1秒)"
else
    echo "🐌 評価: 低速 (1秒以上)"
fi

# include依存関係分析
echo ""
echo "🔍 Makefile構造分析"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

include_count=$(grep -c "^include" Makefile 2>/dev/null || echo "0")
mk_files=$(find mk/ -name "*.mk" 2>/dev/null | wc -l)
total_lines=$(find . -name "*.mk" -o -name "Makefile" | xargs wc -l | tail -1 | awk '{print $1}')

echo "📁 includeファイル数: $include_count"
echo "📄 mkファイル数: $mk_files"
echo "📏 総行数: $total_lines"

# 最も重いmkファイルを特定
echo ""
echo "📊 ファイル別行数 (上位5個):"
find mk/ -name "*.mk" 2>/dev/null | xargs wc -l | sort -nr | head -5 | while read lines file; do
    echo "  📄 $file: $lines 行"
done

# パフォーマンス改善提案
echo ""
echo "💡 最適化提案:"
if (( execution_time > 500 )); then
    echo "  • include順序の最適化"
    echo "  • 不要な依存関係の削除"
    echo "  • 条件分岐による処理軽量化"
fi

if (( total_lines > 5000 )); then
    echo "  • 大きなmkファイルの分割検討"
fi

echo "  • キャッシュ機構の導入"
echo "  • 並列実行の活用"

# ログに記録
echo "$(date '+%Y-%m-%d %H:%M:%S'),$TARGET,$execution_time,$make_exit_code,$include_count,$total_lines" >> "$LOG_FILE"

echo ""
echo "📝 ログ保存: $LOG_FILE"
echo "🏁 プロファイリング完了"


