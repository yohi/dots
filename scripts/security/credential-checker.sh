#!/bin/bash
# 機密情報検証スクリプト
# 使用方法: ./credential-checker.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 色コード定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 Dotfiles セキュリティチェック${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 対象ディレクトリ: $DOTFILES_DIR"
echo "📊 チェック開始: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

cd "$DOTFILES_DIR" || { echo "cd failed: $DOTFILES_DIR"; exit 1; }

# ログファイル設定
TS="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$SCRIPT_DIR/security-scan-${TS}.log"

# 全出力をログファイルにも保存
exec > >(tee -a "$LOG_FILE") 2>&1

# GREP コマンド解決（PCRE優先）
resolve_grep() {
    if command -v rg >/dev/null 2>&1; then
        # ripgrep: オプション整合
        printf 'rg --pcre2 -n -i --no-messages -S'
    elif echo "" | grep -P "" >/dev/null 2>&1; then
        printf 'grep -r -I -n -i -P'
    elif command -v ggrep >/dev/null 2>&1 && echo "" | ggrep -P "" >/dev/null 2>&1; then
        printf 'ggrep -r -I -n -i -P'
    else
        # 最低限のフォールバック（POSIX EREに合わせてパターン要調整）
        printf 'grep -r -I -n -i -E'
    fi
}

# ポータブルな8進数権限取得関数
get_octal_perm() {
    local file="$1"
    if stat -c "%a" "$file" 2>/dev/null; then
        # GNU stat (Linux)
        return 0
    elif stat -f "%OLp" "$file" 2>/dev/null; then
        # BSD stat (macOS)
        return 0
    else
        # フォールバック: ls -l から推定
        local perms=$(ls -l "$file" | cut -c2-10)
        local octal=""
        for i in 0 3 6; do
            local rwx=${perms:$i:3}
            local val=0
            [[ ${rwx:0:1} == "r" ]] && ((val += 4))
            [[ ${rwx:1:1} == "w" ]] && ((val += 2))
            [[ ${rwx:2:1} == "x" || ${rwx:2:1} == "s" || ${rwx:2:1} == "t" ]] && ((val += 1))
            octal+="$val"
        done
        printf "%s" "$octal"
    fi
}

# 検出カウンタ
ISSUES_FOUND=0
HIGH_RISK=0
MEDIUM_RISK=0
LOW_RISK=0

# 1. ハードコードされた機密情報の検出
echo -e "${BLUE}🔍 ハードコードされた機密情報チェック${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 高リスクパターン
declare -a HIGH_RISK_PATTERNS=(
    "password\s*=\s*['\"][^'\"]*['\"]"
    "secret\s*=\s*['\"][^'\"]*['\"]"
    "api_key\s*=\s*['\"][^'\"]*['\"]"
    "token\s*=\s*['\"][^'\"]*['\"]"
    "private_key\s*=\s*['\"][^'\"]*['\"]"
)

# 中リスクパターン
declare -a MEDIUM_RISK_PATTERNS=(
    "YOUR_.*_HERE"
    "REPLACE_WITH_"
    "CHANGEME"
    "defaultpassword"
)

echo "🔴 高リスク検出:"
CMD="$(resolve_grep)"
for pattern in "${HIGH_RISK_PATTERNS[@]}"; do
    if $CMD --exclude-dir=.git --exclude="*.backup.*" "$pattern" . >/dev/null 2>&1; then
        echo -e "${RED}  ⚠️  パターン: $pattern${NC}"
        while IFS= read -r line; do
            echo "    📄 ${line}"
        done < <($CMD --exclude-dir=.git --exclude="*.backup.*" "$pattern" . 2>/dev/null)
        ((HIGH_RISK++))
        ((ISSUES_FOUND++))
    fi
done

echo ""
echo "🟡 中リスク検出:"
for pattern in "${MEDIUM_RISK_PATTERNS[@]}"; do
    if $CMD --exclude-dir=.git --exclude="*.backup.*" "$pattern" . >/dev/null 2>&1; then
        echo -e "${YELLOW}  ⚠️  パターン: $pattern${NC}"
        while IFS= read -r line; do
            echo "    📄 ${line}"
        done < <($CMD --exclude-dir=.git --exclude="*.backup.*" "$pattern" . 2>/dev/null)
        ((MEDIUM_RISK++))
        ((ISSUES_FOUND++))
    fi
done

# 2. 機密設定ファイルの存在確認
echo ""
echo -e "${BLUE}🗂️  機密設定ファイルチェック${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# チェック対象ファイル
declare -a SENSITIVE_FILES=(
    ".env"
    ".env.local"
    ".env.secret"
    "cursor/mcp.local.json"
    ".aws/credentials"
    ".ssh/id_rsa"
    ".gnupg/secring.gpg"
)

echo "🔍 機密ファイル検索:"
for file in "${SENSITIVE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        if grep -q "$file" .gitignore 2>/dev/null; then
            echo -e "  ✅ $file ${GREEN}(gitignore済み)${NC}"
        else
            echo -e "  ${RED}⚠️  $file (gitignore未設定!)${NC}"
            ((HIGH_RISK++))
            ((ISSUES_FOUND++))
        fi
    else
        echo -e "  📝 $file ${BLUE}(未存在)${NC}"
    fi
done

# 3. 環境変数設定の確認
echo ""
echo -e "${BLUE}🌍 環境変数設定チェック${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

declare -a REQUIRED_ENV_VARS=(
    "BITBUCKET_USERNAME"
    "BITBUCKET_APP_PASSWORD"
    "GEMINI_API_KEY"
)

echo "🔍 必要な環境変数:"
for var in "${REQUIRED_ENV_VARS[@]}"; do
    if [[ ! -z "${!var}" ]]; then
        echo -e "  ✅ $var ${GREEN}(設定済み)${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $var (未設定)${NC}"
        ((MEDIUM_RISK++))
        ((ISSUES_FOUND++))
    fi
done

# 4. ファイル権限チェック
echo ""
echo -e "${BLUE}🔐 ファイル権限チェック${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 実行可能ファイルのチェック
echo "🔍 実行権限ファイル:"
find . -type f -perm -111 ! -path "./.git/*" | while read -r file; do
    perm=$(get_octal_perm "$file")
    other_exec=${perm:2:1}
    if [[ "$other_exec" -ge 1 ]]; then
      echo -e "  ${YELLOW}⚠️  $file ($perm) - others に実行権限${NC}"
      ((LOW_RISK++)); ((ISSUES_FOUND++))
    else
      echo -e "  ✅ $file ${GREEN}($perm)${NC}"
    fi
done

# 5. 総合評価
echo ""
echo -e "${BLUE}📊 セキュリティ評価${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔴 高リスク問題: $HIGH_RISK 件"
echo "🟡 中リスク問題: $MEDIUM_RISK 件"
echo "🟠 低リスク問題: $LOW_RISK 件"
echo "📊 総問題数: $ISSUES_FOUND 件"

# スコア計算（100点満点）
SCORE=$((100 - (HIGH_RISK * 20) - (MEDIUM_RISK * 10) - (LOW_RISK * 5)))
if [[ $SCORE -lt 0 ]]; then
    SCORE=0
fi

echo ""
echo "🎯 セキュリティスコア: $SCORE/100"

if [[ $SCORE -ge 90 ]]; then
    echo -e "${GREEN}🛡️  評価: 優秀 - セキュリティレベルが高いです${NC}"
elif [[ $SCORE -ge 75 ]]; then
    echo -e "${BLUE}🔒 評価: 良好 - 概ね安全です${NC}"
elif [[ $SCORE -ge 60 ]]; then
    echo -e "${YELLOW}⚠️  評価: 要注意 - いくつかの問題があります${NC}"
else
    echo -e "${RED}🚨 評価: 危険 - 早急な対応が必要です${NC}"
fi

# 改善提案
echo ""
echo -e "${BLUE}💡 セキュリティ改善提案${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $HIGH_RISK -gt 0 ]]; then
    echo "🔴 緊急対応が必要:"
    echo "  • ハードコードされた機密情報を環境変数に移行"
    echo "  • .gitignoreの設定を確認・更新"
    echo "  • 既にコミットされた機密情報がある場合は履歴削除を検討"
fi

if [[ $MEDIUM_RISK -gt 0 ]]; then
    echo "🟡 推奨改善:"
    echo "  • 環境変数の設定完了"
    echo "  • 設定テンプレートファイルの作成"
    echo "  • セットアップドキュメントの更新"
fi

if [[ $LOW_RISK -gt 0 ]]; then
    echo "🟠 軽微な改善:"
    echo "  • ファイル権限の適正化"
    echo "  • 不要な実行権限の削除"
fi

echo ""
echo "📝 ログ保存: $LOG_FILE"
echo "🏁 セキュリティチェック完了"
