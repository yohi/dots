#!/usr/bin/env zsh
# ===================================================================
# AWS関連カスタム関数
# ===================================================================

# 共通関数: AWSプロファイル選択
_aws_select_profile() {
    echo "📋 利用可能なAWSプロファイルを検索中..."
    local profiles=($(aws configure list-profiles 2>/dev/null))
    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo "❌ AWSプロファイルが見つかりません。'aws configure' でプロファイルを設定してください。"
        return 1
    fi

    local fzf_input=""
    for p in "${profiles[@]}"; do
        fzf_input+="$p"
        [[ "$p" == "default" ]] && fzf_input+=" (default)"
        [[ "$p" == "${AWS_PROFILE:-default}" ]] && fzf_input+=" (current)"
        fzf_input+="\n"
    done

    local selected_line=$(echo -e "$fzf_input" | fzf --prompt="AWSプロファイルを選択してください: " --layout=reverse --border)
    if [[ -z "$selected_line" ]]; then
        echo "❌ プロファイルが選択されませんでした。"
        return 1
    fi

    profile=$(echo "$selected_line" | awk '{print $1}')
    export AWS_PROFILE="$profile"

    echo "✅ プロファイル '$profile' を選択しました。"
    return 0
}

# EC2インスタンス一覧表示
ec2-list() {
    local profile="${AWS_PROFILE:-default}"
    echo "📋 EC2インスタンス一覧 (プロファイル: $profile)"

    aws ec2 describe-instances \
        --profile "$profile" \
        --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0],PublicIpAddress,PrivateIpAddress]' \
        --output table
}

# EC2インスタンス接続
ec2-ssm() {
    echo "🚀 EC2 SSM接続ツール"

    # プロファイル選択
    _aws_select_profile || return 1

    echo "📋 SSM対応EC2インスタンスを検索中..."
    local instance_info=$(aws ec2 describe-instances \
        --profile "$AWS_PROFILE" \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[?PlatformDetails!=`Windows`].[InstanceId, Tags[?Key==`Name`].Value | [0], PrivateIpAddress]' \
        --output text)

    if [[ -z "$instance_info" ]]; then
        echo "❌ 実行中のEC2インスタンスが見つかりません。"
        return 1
    fi

    # インスタンス選択
    local selected_instance_line=$(echo "$instance_info" | fzf --prompt="接続するEC2インスタンスを選択: " --layout=reverse --border --header="InstanceID / Name / PrivateIP")
    local selected_instance=$(echo "$selected_instance_line" | awk '{print $1}')
    if [[ -z "$selected_instance" ]]; then
        echo "❌ インスタンスが選択されませんでした。"
        return 1
    fi

    echo "🔗 EC2インスタンス $selected_instance に接続中..."

    # SSM接続実行
    aws ssm start-session --target "$selected_instance" --profile "$AWS_PROFILE"
}

# ECSクラスター一覧
ecs-list() {
    local profile="${AWS_PROFILE:-default}"
    echo "📋 ECSクラスター一覧 (プロファイル: $profile)"

    aws ecs list-clusters \
        --profile "$profile" \
        --query 'clusterArns[]' \
        --output table
}

# CloudWatch Logs表示
awslogs() {
    echo "📋 CloudWatch Logs表示ツール"
    local verbose=false
    # シンプルな引数チェック
    if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
        verbose=true
    fi

    # プロファイル選択
    _aws_select_profile || return 1

    # ロググループ選択
    echo "📋 ロググループを検索中..."
    local log_groups=($(aws logs describe-log-groups --profile "$AWS_PROFILE" --query 'logGroups[].logGroupName' --output text))

    if [[ ${#log_groups[@]} -eq 0 ]]; then
        echo "❌ ロググループが見つかりません。"
        return 1
    fi

    local selected_log_group=$(printf '%s\n' "${log_groups[@]}" | fzf --prompt="ロググループを選択: " --layout=reverse --border)
    if [[ -z "$selected_log_group" ]]; then
        echo "❌ ロググループが選択されませんでした。"
        return 1
    fi

    # evalを使うため、変数をシングルクォートで囲んで安全性を高める
    local safe_log_group=$(printf "%q" "$selected_log_group")
    local tail_command="aws logs tail $safe_log_group --follow --profile \"$AWS_PROFILE\""

    if [[ "$verbose" == "true" ]]; then
        echo "📋 ログを詳細表示でストリーミングします... (Ctrl+Cで終了) ($selected_log_group)"
        eval "$tail_command"
    else
        echo "📋 ログを簡易表示でストリーミングします... (Ctrl+Cで終了) ($selected_log_group)"
        # タイムスタンプとメッセージのみ表示 (ログストリーム名を削除)
        # sed -uでパイプのバッファリングを無効化
        eval "$tail_command" | sed -u -E 's/^(\S+T\S+)\s+\S+\s+(.*)/\1 \2/'
    fi
}

# AWS関数ヘルプ
aws-help() {
    echo "🛠️  AWS関連カスタム関数ヘルプ"
    echo ""
    echo "📋 利用可能な関数:"
    echo ""
    echo "  🖥️  EC2関連:"
    echo "    ec2-list    : EC2インスタンス一覧表示"
    echo "    ec2-ssm     : EC2インスタンスにSSM経由で接続"
    echo ""
    echo "  🐳 ECS関連:"
    echo "    ecs-list    : ECSクラスター一覧表示"
    echo ""
    echo "  📊 CloudWatch関連:"
    echo "    awslogs     : CloudWatch Logsの表示"
    echo ""
    echo "  ❓ その他:"
    echo "    aws-help    : このヘルプを表示"
    echo ""
    echo "📝 前提条件:"
    echo "  - AWS CLI v2"
    echo "  - AWS Session Manager Plugin (SSM用)"
    echo "  - fzf (fuzzy finder)"
    echo "  - 適切なIAM権限"
    echo ""
    echo "🔧 設定:"
    echo "  aws configure         # プロファイル設定"
    echo "  export AWS_PROFILE=名前  # デフォルトプロファイル設定"
}

echo "✅ AWS関数が読み込まれました。'aws-help' でヘルプを表示できます。"
