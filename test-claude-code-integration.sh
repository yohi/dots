#!/bin/bash

# Claude Code CLI統合テストスクリプト
# 要件 5.1, 5.2 に対応

set -e

echo "🧪 Claude Code CLI統合テストを開始します..."
echo "=================================="
echo ""

# テスト結果を記録する変数
TESTS_PASSED=0
TESTS_FAILED=0
TEST_RESULTS=()

# テスト結果を記録する関数
record_test() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    if [ "$result" = "PASS" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✅ $test_name: $message"
        TEST_RESULTS+=("✅ $test_name: $message")
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "❌ $test_name: $message"
        TEST_RESULTS+=("❌ $test_name: $message")
    fi
}

# 1. 新規環境でのインストールテスト
echo "🔍 テスト1: 新規環境でのインストールテスト"
echo "----------------------------------------"

# Claude Codeが既にインストールされているかチェック
if command -v claude >/dev/null 2>&1; then
    echo "ℹ️  Claude Code CLIが既にインストールされています"
    echo "📋 現在のバージョン: $(claude --version 2>/dev/null || echo 'バージョン取得不可')"
    
    # 既存インストール環境でのスキップテスト
    echo ""
    echo "🔍 テスト2: 既存インストール環境でのスキップテスト"
    echo "----------------------------------------------"
    
    echo "📝 install-claude-codeターゲットを実行してスキップ動作を確認..."
    if make install-claude-code 2>&1 | grep -q "既にインストールされています"; then
        record_test "既存インストールスキップ" "PASS" "既存インストール時に適切にスキップされました"
    else
        record_test "既存インストールスキップ" "FAIL" "既存インストール時のスキップ動作が正しく動作しませんでした"
    fi
    
    # 検証機能のテスト
    echo ""
    echo "🔍 テスト3: インストール検証機能のテスト"
    echo "------------------------------------"
    
    echo "📝 verify-claude-codeターゲットを実行..."
    if make verify-claude-code >/dev/null 2>&1; then
        record_test "インストール検証" "PASS" "verify-claude-codeが正常に実行されました"
    else
        record_test "インストール検証" "FAIL" "verify-claude-codeの実行に失敗しました"
    fi
    
else
    echo "ℹ️  Claude Code CLIがインストールされていません - 新規インストールテストを実行"
    
    # Node.js環境の確認
    echo "📝 Node.js環境を確認中..."
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [ -n "$NODE_VERSION" ] && [ "$NODE_VERSION" -ge 18 ] 2>/dev/null; then
            echo "✅ Node.js v$(node --version | sed 's/v//') が利用可能です"
            
            # 新規インストールテスト
            echo "📝 install-claude-codeターゲットを実行..."
            if make install-claude-code; then
                record_test "新規インストール" "PASS" "Claude Code CLIが正常にインストールされました"
                
                # インストール後の確認
                if command -v claude >/dev/null 2>&1; then
                    record_test "インストール後確認" "PASS" "claudeコマンドが実行可能になりました"
                else
                    record_test "インストール後確認" "FAIL" "インストール後もclaudeコマンドが見つかりません"
                fi
            else
                record_test "新規インストール" "FAIL" "Claude Code CLIのインストールに失敗しました"
            fi
        else
            record_test "Node.js環境" "FAIL" "Node.js 18以上が必要です（現在: v$(node --version 2>/dev/null | sed 's/v//' || echo '不明')）"
        fi
    else
        record_test "Node.js環境" "FAIL" "Node.jsがインストールされていません"
    fi
fi

# 4. バッチインストールでの統合テスト
echo ""
echo "🔍 テスト4: バッチインストールでの統合テスト"
echo "----------------------------------------"

echo "📝 install-appsターゲットにClaude Codeが含まれているか確認..."
if make -n install-apps 2>&1 | grep -q "install-claude-code"; then
    record_test "install-apps統合" "PASS" "install-appsターゲットにClaude Codeが含まれています"
else
    record_test "install-apps統合" "FAIL" "install-appsターゲットにClaude Codeが含まれていません"
fi

echo "📝 setup-allターゲットでClaude Codeがインストールされるか確認..."
if make -n setup-all 2>&1 | grep -q "install-apps"; then
    record_test "setup-all統合" "PASS" "setup-allターゲット経由でClaude Codeがインストールされます"
else
    record_test "setup-all統合" "FAIL" "setup-allターゲットでClaude Codeがインストールされません"
fi

# 5. 階層的命名規則のテスト
echo ""
echo "🔍 テスト5: 階層的命名規則のテスト"
echo "------------------------------"

echo "📝 install-packages-claude-codeエイリアスを確認..."
if make -n install-packages-claude-code 2>&1 | grep -q "install-claude-code"; then
    record_test "階層的命名規則" "PASS" "install-packages-claude-codeエイリアスが正しく設定されています"
else
    record_test "階層的命名規則" "FAIL" "install-packages-claude-codeエイリアスが正しく設定されていません"
fi

# 6. ヘルプシステムのテスト
echo ""
echo "🔍 テスト6: ヘルプシステムのテスト"
echo "----------------------------"

echo "📝 ヘルプメッセージにClaude Codeが含まれているか確認..."
if make help 2>&1 | grep -q "claude-code"; then
    record_test "ヘルプシステム" "PASS" "ヘルプメッセージにClaude Code関連項目が含まれています"
else
    record_test "ヘルプシステム" "FAIL" "ヘルプメッセージにClaude Code関連項目が含まれていません"
fi

# テスト結果のサマリー
echo ""
echo "📊 テスト結果サマリー"
echo "=================="
echo "✅ 成功: $TESTS_PASSED"
echo "❌ 失敗: $TESTS_FAILED"
echo "📋 合計: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

echo "📋 詳細結果:"
for result in "${TEST_RESULTS[@]}"; do
    echo "  $result"
done

echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 すべてのテストが成功しました！"
    exit 0
else
    echo "⚠️  $TESTS_FAILED 個のテストが失敗しました。上記の詳細を確認してください。"
    exit 1
fi