#!/usr/bin/env zsh

# RDS-SSM接続関数
# SSM経由でRDSインスタンスに接続する統合機能
#
# 機能:
# - AWS プロファイル選択
# - SSM接続可能なEC2インスタンス選択
# - RDSインスタンス選択
# - IAM認証/パスワード認証の自動判定
# - 安全なSSMポートフォワーディング接続

rds-ssm() {
    local profile=""
    local instance_id=""
    local rds_endpoint=""
    local db_name=""
    local db_user=""
    local db_engine=""
    local use_iam_auth=""
    local rds_port=""
    local local_port=""

    # ヘルプ表示
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        _rds_ssm_show_help
        return 0
    fi

    echo "🚀 RDS-SSM接続ツールを開始します..."
    echo

    # Step 1: AWS Profile選択
    if ! _rds_ssm_select_profile; then
        echo "❌ AWSプロファイル選択に失敗しました"
        return 1
    fi

    # Step 2: SSM接続可能なEC2インスタンス選択
    if ! _rds_ssm_select_ec2_instance; then
        echo "❌ EC2インスタンス選択に失敗しました"
        return 1
    fi

    # Step 3: RDSインスタンス選択
    if ! _rds_ssm_select_rds_instance; then
        echo "❌ RDSインスタンス選択に失敗しました"
        return 1
    fi

    # Step 4: 接続情報入力
    if ! _rds_ssm_input_connection_info; then
        echo "❌ 接続情報入力に失敗しました"
        return 1
    fi

    # Step 5: IAM認証チェックとトークン生成
    if ! _rds_ssm_setup_authentication; then
        echo "❌ 認証設定に失敗しました"
        return 1
    fi

    # Step 6: SSMポートフォワーディング開始
    if ! _rds_ssm_start_port_forwarding; then
        echo "❌ ポートフォワーディング開始に失敗しました"
        return 1
    fi

    # Step 7: データベース接続
    _rds_ssm_connect_to_database
}

# ヘルプ表示
_rds_ssm_show_help() {
    cat << 'EOF'
🔧 RDS-SSM接続ツール

USAGE:
    rds-ssm [OPTIONS]

OPTIONS:
    -h, --help    このヘルプを表示

DESCRIPTION:
    SSM Session Manager経由でRDSインスタンスに安全に接続します。

FEATURES:
    ✅ AWS プロファイル選択
    ✅ SSM対応EC2インスタンス自動検出・選択
    ✅ RDSインスタンス一覧・選択
    ✅ IAM認証/パスワード認証自動判定
    ✅ 安全なSSMポートフォワーディング
    ✅ MySQL/PostgreSQL対応

REQUIREMENTS:
    - aws-cli (v2)
    - session-manager-plugin
    - mysql-client または postgresql-client

EXAMPLES:
    rds-ssm                 # 対話式でRDS接続を開始
    rds-ssm --help         # ヘルプ表示

NOTES:
    - EC2インスタンスにはSSM Agent及び適切なIAMロールが必要
    - RDSインスタンスへのネットワークアクセスが可能なEC2を選択してください
    - IAM認証を使用する場合は、適切なRDSアクセス権限が必要
EOF
}

# AWS Profile選択
_rds_ssm_select_profile() {
    echo "📋 利用可能なAWSプロファイル:"

    local profiles=($(aws configure list-profiles 2>/dev/null))

    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo "❌ AWSプロファイルが見つかりません"
        echo "💡 'aws configure' でプロファイルを設定してください"
        return 1
    fi

    # プロファイル一覧表示
    for i in {1..${#profiles[@]}}; do
        local current_profile="${profiles[$i]}"
        printf "  %2d) %s" $i "$current_profile"

        # デフォルトプロファイルマーク
        if [[ "$current_profile" == "default" ]]; then
            printf " (default)"
        fi

        # 現在のプロファイルマーク
        if [[ "$current_profile" == "${AWS_PROFILE:-default}" ]]; then
            printf " (current)"
        fi

        echo
    done

    echo
    printf "プロファイルを選択してください [1-${#profiles[@]}]: "
    read selection

    # 入力検証
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#profiles[@]} ]]; then
        echo "❌ 無効な選択です"
        return 1
    fi

    profile="${profiles[$selection]}"
    export AWS_PROFILE="$profile"

    echo "✅ プロファイル '$profile' を選択しました"
    echo

    # AWS認証情報確認
    if ! aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        echo "❌ AWS認証に失敗しました。プロファイル設定を確認してください"
        return 1
    fi

    local account_id=$(aws sts get-caller-identity --profile "$profile" --query 'Account' --output text)
    local user_arn=$(aws sts get-caller-identity --profile "$profile" --query 'Arn' --output text)

    echo "🔐 認証情報確認完了:"
    echo "   Account ID: $account_id"
    echo "   User ARN: $user_arn"
    echo

    return 0
}

# SSM接続可能なEC2インスタンス選択
_rds_ssm_select_ec2_instance() {
    echo "🖥️  SSM接続可能なEC2インスタンスを検索中..."

    # SSM管理対象インスタンス取得
    local ssm_instances=$(aws ssm describe-instance-information \
        --profile "$profile" \
        --query 'InstanceInformationList[?PingStatus==`Online`].[InstanceId,ComputerName,PlatformType,PlatformName]' \
        --output text 2>/dev/null)

    if [[ -z "$ssm_instances" ]]; then
        echo "❌ SSM接続可能なEC2インスタンスが見つかりません"
        echo "💡 EC2インスタンスにSSM Agentがインストールされ、適切なIAMロールが設定されているか確認してください"
        return 1
    fi

    # EC2インスタンス詳細情報取得
    local instance_ids=($(echo "$ssm_instances" | awk '{print $1}'))
    local instance_details=$(aws ec2 describe-instances \
        --profile "$profile" \
        --instance-ids "${instance_ids[@]}" \
        --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0],InstanceType,State.Name,PrivateIpAddress,PublicIpAddress]' \
        --output text 2>/dev/null)

    echo "📋 利用可能なEC2インスタンス:"
    echo

    local instances=()
    local instance_info=()
    local count=1

    while IFS=$'\t' read -r inst_id name inst_type state private_ip public_ip; do
        # SSMオンラインインスタンスのみ
        if echo "$ssm_instances" | grep -q "^$inst_id"; then
            instances+=("$inst_id")

            # 表示用情報整理
            local display_name="${name:-"(名前なし)"}"
            local display_public_ip="${public_ip:-"なし"}"
            local display_private_ip="${private_ip:-"なし"}"

            printf "  %2d) %s\n" $count "$display_name"
            printf "      ID: %s\n" "$inst_id"
            printf "      タイプ: %s | 状態: %s\n" "$inst_type" "$state"
            printf "      プライベートIP: %s | パブリックIP: %s\n" "$display_private_ip" "$display_public_ip"
            echo

            instance_info+=("$inst_id|$display_name|$inst_type|$state|$display_private_ip")
            ((count++))
        fi
    done <<< "$instance_details"

    if [[ ${#instances[@]} -eq 0 ]]; then
        echo "❌ 利用可能なEC2インスタンスが見つかりません"
        return 1
    fi

    printf "EC2インスタンスを選択してください [1-${#instances[@]}]: "
    read selection

    # 入力検証
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#instances[@]} ]]; then
        echo "❌ 無効な選択です"
        return 1
    fi

    instance_id="${instances[$selection]}"
    local selected_info="${instance_info[$selection]}"
    local selected_name=$(echo "$selected_info" | cut -d'|' -f2)

    echo "✅ EC2インスタンス '$selected_name' ($instance_id) を選択しました"
    echo

    # SSM接続テスト
    echo "🔗 SSM接続をテスト中..."
    if ! timeout 10 aws ssm start-session \
        --profile "$profile" \
        --target "$instance_id" \
        --document-name "AWS-StartShellSession" \
        --parameters 'command=["echo SSM_CONNECTION_TEST_OK"]' >/dev/null 2>&1; then

        echo "⚠️  警告: SSM接続テストが失敗しました。接続時に問題が発生する可能性があります"
        printf "続行しますか? [y/N]: "
        read continue_choice
        if [[ ! "$continue_choice" =~ ^[yY]$ ]]; then
            return 1
        fi
    else
        echo "✅ SSM接続テスト成功"
    fi
    echo

    return 0
}

# RDSインスタンス選択
_rds_ssm_select_rds_instance() {
    echo "🗄️  RDSインスタンスを検索中..."

    # RDSインスタンス一覧取得
    local rds_instances=$(aws rds describe-db-instances \
        --profile "$profile" \
        --query 'DBInstances[?DBInstanceStatus==`available`].[DBInstanceIdentifier,Engine,EngineVersion,DBInstanceClass,Endpoint.Address,Endpoint.Port,IAMDatabaseAuthenticationEnabled,MultiAZ]' \
        --output text 2>/dev/null)

    if [[ -z "$rds_instances" ]]; then
        echo "❌ 利用可能なRDSインスタンスが見つかりません"
        return 1
    fi

    echo "📋 利用可能なRDSインスタンス:"
    echo

    local instances=()
    local instance_info=()
    local count=1

    while IFS=$'\t' read -r db_id engine engine_ver db_class endpoint port iam_auth multi_az; do
        instances+=("$db_id")

        printf "  %2d) %s\n" $count "$db_id"
        printf "      エンジン: %s %s\n" "$engine" "$engine_ver"
        printf "      クラス: %s | MultiAZ: %s\n" "$db_class" "$multi_az"
        printf "      エンドポイント: %s:%s\n" "$endpoint" "$port"
        printf "      IAM認証: %s\n" "$([[ "$iam_auth" == "true" ]] && echo "✅ 有効" || echo "❌ 無効")"
        echo

        instance_info+=("$db_id|$engine|$endpoint|$port|$iam_auth")
        ((count++))
    done <<< "$rds_instances"

    printf "RDSインスタンスを選択してください [1-${#instances[@]}]: "
    read selection

    # 入力検証
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#instances[@]} ]]; then
        echo "❌ 無効な選択です"
        return 1
    fi

    local selected_info="${instance_info[$selection]}"
    rds_endpoint=$(echo "$selected_info" | cut -d'|' -f3)
    rds_port=$(echo "$selected_info" | cut -d'|' -f4)
    db_engine=$(echo "$selected_info" | cut -d'|' -f2)
    use_iam_auth=$(echo "$selected_info" | cut -d'|' -f5)

    echo "✅ RDSインスタンス '${instances[$selection]}' を選択しました"
    echo "   エンジン: $db_engine"
    echo "   エンドポイント: $rds_endpoint:$rds_port"
    echo "   IAM認証: $([[ "$use_iam_auth" == "true" ]] && echo "有効" || echo "無効")"
    echo

    return 0
}

# 接続情報入力
_rds_ssm_input_connection_info() {
    echo "🔧 データベース接続情報を入力してください:"
    echo

    # データベース名入力
    printf "データベース名: "
    read db_name
    if [[ -z "$db_name" ]]; then
        echo "❌ データベース名は必須です"
        return 1
    fi

    # ユーザー名入力
    printf "ユーザー名: "
    read db_user
    if [[ -z "$db_user" ]]; then
        echo "❌ ユーザー名は必須です"
        return 1
    fi

    # ローカルポート番号設定
    local_port=$((rds_port + 10000))
    printf "ローカルポート番号 [%d]: " $local_port
    read custom_port
    if [[ -n "$custom_port" ]]; then
        if [[ "$custom_port" =~ ^[0-9]+$ ]] && [[ $custom_port -ge 1024 ]] && [[ $custom_port -le 65535 ]]; then
            local_port=$custom_port
        else
            echo "❌ 無効なポート番号です (1024-65535)"
            return 1
        fi
    fi

    echo
    echo "✅ 接続情報:"
    echo "   データベース: $db_name"
    echo "   ユーザー: $db_user"
    echo "   ローカルポート: $local_port"
    echo

    return 0
}

# 認証設定 (IAM認証/パスワード認証)
_rds_ssm_setup_authentication() {
    if [[ "$use_iam_auth" == "true" ]]; then
        echo "🔐 IAM認証が有効です。認証トークンを生成中..."

        # IAM認証トークン生成
        local auth_token=$(aws rds generate-db-auth-token \
            --profile "$profile" \
            --hostname "$rds_endpoint" \
            --port "$rds_port" \
            --username "$db_user" \
            2>/dev/null)

        if [[ -z "$auth_token" ]]; then
            echo "❌ IAM認証トークンの生成に失敗しました"
            echo "💡 IAMユーザー/ロールにrds-db:connect権限があるか確認してください"
            return 1
        fi

        export RDS_AUTH_TOKEN="$auth_token"
        echo "✅ IAM認証トークンを生成しました"
        echo "   有効期限: 15分"
        echo

    else
        echo "🔑 パスワード認証を使用します"
        printf "データベースパスワード: "
        read -s db_password
        echo

        if [[ -z "$db_password" ]]; then
            echo "❌ パスワードは必須です"
            return 1
        fi

        export RDS_PASSWORD="$db_password"
        echo "✅ パスワードを設定しました"
        echo
    fi

    return 0
}

# SSMポートフォワーディング開始
_rds_ssm_start_port_forwarding() {
    echo "🔗 SSMポートフォワーディングを開始中..."

    # 既存のポートフォワーディングプロセス確認・終了
    local existing_pids=$(lsof -ti:$local_port 2>/dev/null)
    if [[ -n "$existing_pids" ]]; then
        echo "⚠️  ポート $local_port は既に使用中です。既存プロセスを終了します..."
        echo "$existing_pids" | xargs kill -9 2>/dev/null
        sleep 2
    fi

    # SSMポートフォワーディング開始
    aws ssm start-session \
        --profile "$profile" \
        --target "$instance_id" \
        --document-name "AWS-StartPortForwardingSessionToRemoteHost" \
        --parameters "{\"host\":[\"$rds_endpoint\"],\"portNumber\":[\"$rds_port\"],\"localPortNumber\":[\"$local_port\"]}" \
        > /tmp/rds-ssm-session.log 2>&1 &

    local ssm_pid=$!
    export RDS_SSM_PID="$ssm_pid"

    echo "🔄 ポートフォワーディング接続を待機中..."

    # 接続確認 (最大30秒待機)
    local retry_count=0
    local max_retries=30

    while [[ $retry_count -lt $max_retries ]]; do
        if nc -z localhost $local_port 2>/dev/null; then
            break
        fi

        # プロセス生存確認
        if ! kill -0 $ssm_pid 2>/dev/null; then
            echo "❌ SSMポートフォワーディングプロセスが異常終了しました"
            echo "📄 ログを確認してください: /tmp/rds-ssm-session.log"
            return 1
        fi

        sleep 1
        ((retry_count++))
        printf "."
    done
    echo

    if [[ $retry_count -eq $max_retries ]]; then
        echo "❌ ポートフォワーディング接続がタイムアウトしました"
        kill $ssm_pid 2>/dev/null
        return 1
    fi

    echo "✅ SSMポートフォワーディングが確立されました"
    echo "   ローカル接続: localhost:$local_port → $rds_endpoint:$rds_port"
    echo "   プロセスID: $ssm_pid"
    echo

    # クリーンアップ関数登録（関数実行時のみ）
    trap "_rds_ssm_cleanup" EXIT INT TERM

    return 0
}

# データベース接続
_rds_ssm_connect_to_database() {
    echo "🗄️  データベースに接続中..."

    local client_cmd=""
    local connection_params=""

    # エンジン別クライアント設定
    case "$db_engine" in
        mysql)
            if ! command -v mysql >/dev/null 2>&1; then
                echo "❌ MySQLクライアントがインストールされていません"
                echo "💡 'sudo apt-get install mysql-client' でインストールしてください"
                return 1
            fi

            if [[ "$use_iam_auth" == "true" ]]; then
                connection_params="--host=localhost --port=$local_port --user=$db_user --database=$db_name --ssl-mode=REQUIRED --password=\"$RDS_AUTH_TOKEN\""
            else
                connection_params="--host=localhost --port=$local_port --user=$db_user --database=$db_name --password=\"$RDS_PASSWORD\""
            fi
            client_cmd="mysql $connection_params"
            ;;

        postgres|postgresql)
            if ! command -v psql >/dev/null 2>&1; then
                echo "❌ PostgreSQLクライアントがインストールされていません"
                echo "💡 'sudo apt-get install postgresql-client' でインストールしてください"
                return 1
            fi

            if [[ "$use_iam_auth" == "true" ]]; then
                export PGPASSWORD="$RDS_AUTH_TOKEN"
            else
                export PGPASSWORD="$RDS_PASSWORD"
            fi

            connection_params="--host=localhost --port=$local_port --username=$db_user --dbname=$db_name"
            client_cmd="psql $connection_params"
            ;;

        *)
            echo "❌ 未対応のデータベースエンジン: $db_engine"
            echo "💡 対応エンジン: mysql, postgres"
            return 1
            ;;
    esac

    echo "🚀 データベース接続情報:"
    echo "   エンジン: $db_engine"
    echo "   接続先: localhost:$local_port"
    echo "   データベース: $db_name"
    echo "   ユーザー: $db_user"
    echo "   認証方式: $([[ "$use_iam_auth" == "true" ]] && echo "IAM認証" || echo "パスワード認証")"
    echo

    echo "📄 接続コマンド:"
    echo "   $client_cmd"
    echo

    printf "データベースに接続しますか? [Y/n]: "
    read connect_choice
    if [[ "$connect_choice" =~ ^[nN]$ ]]; then
        echo "ℹ️  接続をスキップしました。上記コマンドを使用して手動で接続できます"
        echo "⚠️  SSMポートフォワーディングは継続中です (PID: $RDS_SSM_PID)"
        echo "   終了するには: kill $RDS_SSM_PID"
        return 0
    fi

    echo "🔗 データベースに接続しています..."
    echo "   (接続を終了するには Ctrl+C を押してください)"
    echo

    # データベース接続実行
    eval "$client_cmd"

    echo
    echo "✅ データベース接続を終了しました"
}

# クリーンアップ（無限ループ防止版）
_rds_ssm_cleanup() {
    # 既にクリーンアップ実行中の場合はスキップ
    [[ "${_RDS_SSM_CLEANUP_RUNNING:-}" == "true" ]] && return 0
    export _RDS_SSM_CLEANUP_RUNNING=true

    # trapを一時的に無効化（再帰防止）
    trap - EXIT INT TERM ERR

    echo
    echo "🧹 クリーンアップ中..."

    # SSMセッション終了
    if [[ -n "${RDS_SSM_PID:-}" ]] && kill -0 "${RDS_SSM_PID}" 2>/dev/null; then
        echo "   SSMポートフォワーディングを終了中 (PID: ${RDS_SSM_PID})..."
        kill "${RDS_SSM_PID}" 2>/dev/null
        wait "${RDS_SSM_PID}" 2>/dev/null
    fi

    # 環境変数クリア
    unset RDS_AUTH_TOKEN RDS_PASSWORD RDS_SSM_PID _RDS_SSM_CLEANUP_RUNNING

    # 一時ファイル削除
    rm -f /tmp/rds-ssm-session.log 2>/dev/null

    echo "✅ クリーンアップ完了"
}

# エラーハンドリング（完全無効化）
# FIXME: trapが無限ループを引き起こすため一時的に無効化
# trap "_rds_ssm_cleanup" ERR

# 注意: rds-ssm関数内でのみtrapを設定するように修正が必要
