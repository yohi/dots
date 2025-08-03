#!/bin/bash

# Claude Code CLIエラーケーステストスクリプト
# 要件 5.4 に対応

set -e

echo "🧪 Claude Code CLIエラーケーステストを開始します..."
echo "=============================================="
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

# 現在の環境をバックアップ
backup_environment() {
    echo "💾 現在の環境をバックアップ中..."
    
    # Node.jsのパスをバックアップ
    if command -v node >/dev/null 2>&1; then
        export ORIGINAL_NODE_PATH=$(which node)
        export ORIGINAL_NODE_VERSION=$(node --version)
        echo "📋 Node.js: $ORIGINAL_NODE_VERSION ($ORIGINAL_NODE_PATH)"
    else
        export ORIGINAL_NODE_PATH=""
        export ORIGINAL_NODE_VERSION=""
        echo "📋 Node.js: 未インストール"
    fi
    
    # npmのパスをバックアップ
    if command -v npm >/dev/null 2>&1; then
        export ORIGINAL_NPM_PATH=$(which npm)
        export ORIGINAL_NPM_VERSION=$(npm --version)
        echo "📋 npm: $ORIGINAL_NPM_VERSION ($ORIGINAL_NPM_PATH)"
    else
        export ORIGINAL_NPM_PATH=""
        export ORIGINAL_NPM_VERSION=""
        echo "📋 npm: 未インストール"
    fi
    
    # PATHをバックアップ
    export ORIGINAL_PATH="$PATH"
    echo "📋 PATH: バックアップ完了"
    echo ""
}

# 環境を復元
restore_environment() {
    echo "🔄 環境を復元中..."
    export PATH="$ORIGINAL_PATH"
    echo "✅ 環境復元完了"
    echo ""
}

# 1. Node.js未インストール環境でのテスト
test_node_not_found() {
    echo "🔍 テスト1: Node.js未インストール環境でのテスト"
    echo "--------------------------------------------"
    
    # PATHからNode.jsを一時的に除外
    echo "📝 Node.jsを一時的に無効化中..."
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v node | grep -v npm | tr '\n' ':' | sed 's/:$//')
    
    # Node.jsが見つからないことを確認
    if ! command -v node >/dev/null 2>&1; then
        echo "✅ Node.jsが正常に無効化されました"
        
        # Claude Codeインストールを試行
        echo "📝 Node.js未インストール環境でinstall-claude-codeを実行..."
        if make install-claude-code 2>&1 | grep -q "Node.jsがインストールされていません"; then
            record_test "Node.js未インストールエラー" "PASS" "適切なエラーメッセージが表示されました"
        else
            record_test "Node.js未インストールエラー" "FAIL" "期待されるエラーメッセージが表示されませんでした"
        fi
        
        # 手動インストール手順が表示されるかテスト
        if make install-claude-code 2>&1 | grep -q "解決方法"; then
            record_test "Node.js未インストール手順表示" "PASS" "手動インストール手順が表示されました"
        else
            record_test "Node.js未インストール手順表示" "FAIL" "手動インストール手順が表示されませんでした"
        fi
    else
        record_test "Node.js無効化" "FAIL" "Node.jsの無効化に失敗しました"
    fi
    
    # 環境を復元
    restore_environment
}

# 2. ネットワークエラー時のテスト
test_network_error() {
    echo "🔍 テスト2: ネットワークエラー時のテスト"
    echo "------------------------------------"
    
    # npmレジストリを無効なURLに変更してネットワークエラーをシミュレート
    echo "📝 npmレジストリを無効なURLに変更中..."
    
    # 現在のnpmレジストリをバックアップ
    ORIGINAL_REGISTRY=$(npm config get registry 2>/dev/null || echo "https://registry.npmjs.org/")
    echo "📋 元のレジストリ: $ORIGINAL_REGISTRY"
    
    # 無効なレジストリを設定
    npm config set registry "https://invalid-registry-url-for-testing.example.com/" 2>/dev/null || true
    
    echo "📝 ネットワークエラー環境でinstall-claude-codeを実行..."
    
    # タイムアウトを短く設定してテストを高速化
    export npm_config_timeout=5000
    export npm_config_fetch_timeout=5000
    
    if timeout 30 make install-claude-code 2>&1 | grep -q "ネットワーク\|network\|timeout\|ENOTFOUND"; then
        record_test "ネットワークエラー検出" "PASS" "ネットワークエラーが適切に検出されました"
    else
        record_test "ネットワークエラー検出" "FAIL" "ネットワークエラーが適切に検出されませんでした"
    fi
    
    # レジストリを復元
    echo "🔄 npmレジストリを復元中..."
    npm config set registry "$ORIGINAL_REGISTRY" 2>/dev/null || true
    unset npm_config_timeout
    unset npm_config_fetch_timeout
    echo "✅ npmレジストリ復元完了"
    echo ""
}

# 3. 権限エラー時のテスト
test_permission_error() {
    echo "🔍 テスト3: 権限エラー時のテスト"
    echo "----------------------------"
    
    # npmのグローバルディレクトリの権限を確認
    echo "📝 npmグローバルディレクトリの権限を確認中..."
    
    NPM_GLOBAL_DIR=$(npm config get prefix 2>/dev/null || echo "/usr/local")
    echo "📋 npmグローバルディレクトリ: $NPM_GLOBAL_DIR"
    
    # 権限エラーをシミュレートするため、一時的にnpmのprefixを書き込み不可能な場所に設定
    echo "📝 権限エラーをシミュレート中..."
    
    # 元のprefixをバックアップ
    ORIGINAL_PREFIX=$(npm config get prefix 2>/dev/null || echo "/usr/local")
    
    # 書き込み不可能なディレクトリを設定
    npm config set prefix "/root/npm-global-test" 2>/dev/null || true
    
    echo "📝 権限エラー環境でinstall-claude-codeを実行..."
    
    if timeout 30 make install-claude-code 2>&1 | grep -q "権限\|permission\|EACCES"; then
        record_test "権限エラー検出" "PASS" "権限エラーが適切に検出されました"
    else
        record_test "権限エラー検出" "FAIL" "権限エラーが適切に検出されませんでした"
    fi
    
    # prefixを復元
    echo "🔄 npmプレフィックスを復元中..."
    npm config set prefix "$ORIGINAL_PREFIX" 2>/dev/null || true
    echo "✅ npmプレフィックス復元完了"
    echo ""
}

# 4. パッケージが見つからない場合のテスト
test_package_not_found() {
    echo "🔍 テスト4: パッケージが見つからない場合のテスト"
    echo "--------------------------------------------"
    
    echo "📝 存在しないパッケージでのインストールをシミュレート..."
    
    # 一時的にmakefileを変更して存在しないパッケージをインストールしようとする
    # これは実際のテストでは危険なので、ログ出力のみをテスト
    
    echo "📝 パッケージ名エラーのログパターンを確認..."
    
    # npmで存在しないパッケージをインストールしようとした場合のエラーメッセージをテスト
    if npm install -g @nonexistent-package/test-package-that-does-not-exist 2>&1 | grep -q "404\|not found\|E404"; then
        record_test "パッケージ未発見エラー" "PASS" "存在しないパッケージのエラーが確認されました"
    else
        record_test "パッケージ未発見エラー" "FAIL" "存在しないパッケージのエラーパターンが確認できませんでした"
    fi
    
    echo ""
}

# 5. エラーハンドリング機能のテスト
test_error_handling() {
    echo "🔍 テスト5: エラーハンドリング機能のテスト"
    echo "--------------------------------------"
    
    echo "📝 エラーハンドリング関数の存在確認..."
    
    # makefileにエラーハンドリング関数が定義されているかチェック
    if grep -q "_claude-code-handle-error" mk/install.mk; then
        record_test "エラーハンドリング関数" "PASS" "エラーハンドリング関数が定義されています"
    else
        record_test "エラーハンドリング関数" "FAIL" "エラーハンドリング関数が定義されていません"
    fi
    
    # 診断情報表示機能の確認
    if grep -q "_claude-code-show-diagnostics" mk/install.mk; then
        record_test "診断情報表示機能" "PASS" "診断情報表示機能が定義されています"
    else
        record_test "診断情報表示機能" "FAIL" "診断情報表示機能が定義されていません"
    fi
    
    # 手動インストール手順表示機能の確認
    if grep -q "_claude-code-show-manual-install" mk/install.mk; then
        record_test "手動インストール手順" "PASS" "手動インストール手順表示機能が定義されています"
    else
        record_test "手動インストール手順" "FAIL" "手動インストール手順表示機能が定義されていません"
    fi
    
    echo ""
}

# メイン実行部分
main() {
    backup_environment
    
    test_node_not_found
    test_network_error
    test_permission_error
    test_package_not_found
    test_error_handling
    
    # テスト結果のサマリー
    echo "📊 エラーケーステスト結果サマリー"
    echo "=============================="
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
        echo "🎉 すべてのエラーケーステストが成功しました！"
        exit 0
    else
        echo "⚠️  $TESTS_FAILED 個のテストが失敗しました。上記の詳細を確認してください。"
        exit 1
    fi
}

# スクリプト実行
main