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

cd "$DOTFILES_DIR"

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
for pattern in "${HIGH_RISK_PATTERNS[@]}"; do
    results=$(grep -r -i -n --exclude-dir=.git --exclude="*.backup.*" "$pattern" . 2>/dev/null)
    if [[ ! -z "$results" ]]; then
        echo -e "${RED}  ⚠️  パターン: $pattern${NC}"
        echo "$results" | while read line; do
            echo "    📄 $line"
        done
        ((HIGH_RISK++))
        ((ISSUES_FOUND++))
    fi
done

echo ""
echo "🟡 中リスク検出:"
for pattern in "${MEDIUM_RISK_PATTERNS[@]}"; do
    results=$(grep -r -i -n --exclude-dir=.git --exclude="*.backup.*" "$pattern" . 2>/dev/null)
    if [[ ! -z "$results" ]]; then
        echo -e "${YELLOW}  ⚠️  パターン: $pattern${NC}"
        echo "$results" | while read line; do
            echo "    📄 $line"
        done
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
find . -type f -executable ! -path "./.git/*" | while read file; do
    perm=$(stat -c "%a" "$file")
    if [[ "$perm" =~ ^7[0-7][0-7]$ ]]; then
        echo -e "  ✅ $file ${GREEN}($perm)${NC}"
    elif [[ "$perm" =~ ^[0-9][0-9][0-9]$ ]] && [[ "${perm:1:1}" -ge "7" || "${perm:2:1}" -ge "7" ]]; then
        echo -e "  ${YELLOW}⚠️  $file ($perm) - 他者実行権限あり${NC}"
        ((LOW_RISK++))
        ((ISSUES_FOUND++))
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
echo "📝 ログ保存: $SCRIPT_DIR/security-scan-$(date +%Y%m%d_%H%M%S).log"
echo "🏁 セキュリティチェック完了"

# 結果をログファイルに保存
LOG_FILE="$SCRIPT_DIR/security-scan-$(date +%Y%m%d_%H%M%S).log"
{
    echo "Security Scan Report - $(date)"
    echo "Score: $SCORE/100"
    echo "High Risk: $HIGH_RISK"
    echo "Medium Risk: $MEDIUM_RISK"
    echo "Low Risk: $LOW_RISK"
    echo "Total Issues: $ISSUES_FOUND"
} > "$LOG_FILE"


