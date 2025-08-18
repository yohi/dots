#!/bin/bash
# Lazygit設定マージスクリプト
# ai-commit-generator/config/lazygit.yml から config.yml へ設定をマージ

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_CONFIG="${SCRIPT_DIR}/config.yml"
AI_CONFIG="${SCRIPT_DIR}/ai-commit-generator/config/lazygit.yml"
BACKUP_CONFIG="${SCRIPT_DIR}/config.yml.backup"

# ファイル存在チェック
if [[ ! -f "${AI_CONFIG}" ]]; then
    echo "❌ エラー: ${AI_CONFIG} が見つかりません"
    exit 1
fi

if [[ ! -f "${MAIN_CONFIG}" ]]; then
    echo "❌ エラー: ${MAIN_CONFIG} が見つかりません"
    exit 1
fi

# バックアップ作成
echo "📄 バックアップ作成: ${BACKUP_CONFIG}"
cp "${MAIN_CONFIG}" "${BACKUP_CONFIG}"

# Python使用可能チェック
if command -v python3 > /dev/null 2>&1; then
    echo "🔄 Python3を使用してYAML設定をマージします..."
    
    # Python スクリプトでYAMLマージ
    python3 -c "
import yaml
import sys
from pathlib import Path

def merge_configs(main_config_path, ai_config_path):
    # AI設定を読み込み
    with open(ai_config_path, 'r', encoding='utf-8') as f:
        ai_config = yaml.safe_load(f)
    
    # メイン設定を読み込み
    with open(main_config_path, 'r', encoding='utf-8') as f:
        main_config = yaml.safe_load(f)
    
    # ai_config の customCommands をメイン設定に上書き
    if 'customCommands' in ai_config:
        main_config['customCommands'] = ai_config['customCommands']
        print(f'✅ {len(ai_config[\"customCommands\"])} 個のカスタムコマンドをマージしました')
    
    # GUI設定も統合（ai_configを優先）
    if 'gui' in ai_config:
        if 'gui' not in main_config:
            main_config['gui'] = {}
        main_config['gui'].update(ai_config['gui'])
        print('✅ GUI設定をマージしました')
    
    return main_config

try:
    merged_config = merge_configs('${MAIN_CONFIG}', '${AI_CONFIG}')
    
    # マージした設定を書き出し
    with open('${MAIN_CONFIG}', 'w', encoding='utf-8') as f:
        yaml.dump(merged_config, f, 
                 default_flow_style=False, 
                 allow_unicode=True, 
                 sort_keys=False)
    
    print('🎉 設定のマージが完了しました')
    
except Exception as e:
    print(f'❌ エラー: {e}', file=sys.stderr)
    sys.exit(1)
"
else
    echo "⚠️  Python3が利用できません。手動でマージを実行します..."
    
    # 手動マージ（ai-commit-generator設定をそのまま使用）
    cp "${AI_CONFIG}" "${MAIN_CONFIG}"
    echo "✅ ai-commit-generator設定をメイン設定にコピーしました"
fi

echo ""
echo "📋 マージ結果の確認:"
echo "  - メイン設定: ${MAIN_CONFIG}"
echo "  - バックアップ: ${BACKUP_CONFIG}"
echo "  - AI設定ソース: ${AI_CONFIG}"
echo ""
echo "🔍 カスタムコマンド数:"
if command -v yq > /dev/null 2>&1; then
    CUSTOM_COMMANDS_COUNT=$(yq eval '.customCommands | length' "${MAIN_CONFIG}" 2>/dev/null || echo "取得できませんでした")
    echo "  現在のコマンド数: ${CUSTOM_COMMANDS_COUNT}"
elif command -v python3 > /dev/null 2>&1; then
    CUSTOM_COMMANDS_COUNT=$(python3 -c "
import yaml
with open('${MAIN_CONFIG}', 'r') as f:
    config = yaml.safe_load(f)
    print(len(config.get('customCommands', [])))
" 2>/dev/null || echo "取得できませんでした")
    echo "  現在のコマンド数: ${CUSTOM_COMMANDS_COUNT}"
fi

echo ""
echo "✅ マージが完了しました！"