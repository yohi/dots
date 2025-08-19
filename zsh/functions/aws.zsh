# ===================================================================
# AWS関連カスタム関数
# ===================================================================

# EC2 SSM接続 (fzf版)
function ec2-ssm() {
    # .aws/credentialsからprofile一覧を取得
    local profile=$(awk '/^\[/{gsub(/\[|\]/, ""); print}' ~/.aws/credentials | fzf --prompt="AWS Profile> " --height=40% --reverse)

    if [[ -z "$profile" ]]; then
        echo "profileが選択されませんでした。"
        return 1
    fi

    echo "Profile: $profile を使用します"

    # 選択されたprofileでEC2インスタンス一覧を取得
    local instance_info=$(aws --profile ${profile} ec2 describe-instances \
        --filter "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0],Placement.AvailabilityZone,InstanceType]' \
        --output text | \
        awk '{
            name = ($2 == "None" || $2 == "") ? "(No Name)" : $2;
            az = $3;
            instance_type = $4;
            printf "%-19s %-30s %-12s %s\n", $1, name, az, instance_type
        }' | \
        fzf --prompt="EC2 Instance> " --height=40% --reverse --header="Instance ID         Name                           AZ           Type")

    if [[ -z "$instance_info" ]]; then
        echo "インスタンスが選択されませんでした。"
        return 1
    fi

    local instance_id=$(echo $instance_info | awk '{print $1}')
    echo "Instance: $instance_id に接続します"

    # SSM接続を実行
    aws --profile ${profile} ssm start-session --target ${instance_id}
}

# ECS タスク接続 (fzf版)
function ecs-exec() {
    # .aws/credentialsからprofile一覧を取得
    local profile=$(awk '/^\[/{gsub(/\[|\]/, ""); print}' ~/.aws/credentials | fzf --prompt="AWS Profile> " --height=40% --reverse)

    if [[ -z "$profile" ]]; then
        echo "profileが選択されませんでした。"
        return 1
    fi

    echo "Profile: $profile を使用します"

    # ECSクラスター一覧を取得
    local cluster_arn=$(aws --profile ${profile} ecs list-clusters \
        --query 'clusterArns[]' \
        --output text | \
        sed 's|.*/||' | \
        fzf --prompt="ECS Cluster> " --height=40% --reverse)

    if [[ -z "$cluster_arn" ]]; then
        echo "クラスターが選択されませんでした。"
        return 1
    fi

    echo "Cluster: $cluster_arn を使用します"

    # 選択されたクラスターでrunning状態のタスク一覧を取得（ECS Exec有効なもののみ）
    echo "ECS Exec有効なタスクを検索中..."
    local task_info=$(aws --profile ${profile} ecs list-tasks \
        --cluster ${cluster_arn} \
        --desired-status RUNNING \
        --query 'taskArns[]' \
        --output text | \
        xargs -I {} aws --profile ${profile} ecs describe-tasks \
        --cluster ${cluster_arn} \
        --tasks {} \
        --query 'tasks[].[taskArn,taskDefinitionArn,lastStatus,enableExecuteCommand]' \
        --output text | \
        awk '{
            split($1, task_parts, "/"); task_id = task_parts[length(task_parts)];
            split($2, td_parts, "/"); td_name = td_parts[length(td_parts)];
            gsub(/:.*/, "", td_name);
            exec_enabled = ($4 == "True") ? "✓" : "✗";
            if($4 == "True") {
                printf "%-32s %-30s %-8s %s\n", task_id, td_name, $3, exec_enabled
            }
        }' | \
        fzf --prompt="ECS Task (Exec有効のみ)> " --height=40% --reverse --header="Task ID                         Task Definition            Status   Exec")

    if [[ -z "$task_info" ]]; then
        echo "ECS Exec有効なタスクが見つからないか、選択されませんでした。"
        echo ""
        echo "ECS Execを有効にするには："
        echo "1. タスク定義で enableExecuteCommand を true に設定"
        echo "2. タスク起動時に --enable-execute-command オプションを指定"
        echo "3. 適切なIAMロールとポリシーを設定"
        return 1
    fi

    local task_id=$(echo $task_info | awk '{print $1}')
    echo "Task: $task_id に接続します"

    # コンテナ一覧を取得（複数コンテナがある場合に対応）
    local container_name=$(aws --profile ${profile} ecs describe-tasks \
        --cluster ${cluster_arn} \
        --tasks ${task_id} \
        --query 'tasks[0].containers[].name' \
        --output text | \
        tr '\t' '\n' | \
        fzf --prompt="Container> " --height=40% --reverse)

    if [[ -z "$container_name" ]]; then
        echo "コンテナが選択されませんでした。"
        return 1
    fi

    echo "Container: $container_name に接続します"

    # ECS Exec接続を実行（bashが利用可能か確認してからshにフォールバック）
    echo "接続中..."
    if ! aws --profile ${profile} ecs execute-command \
        --cluster ${cluster_arn} \
        --task ${task_id} \
        --container ${container_name} \
        --interactive \
        --command "/bin/bash" 2>/dev/null; then

        echo "/bin/bash が利用できません。/bin/sh で再試行します..."
        if ! aws --profile ${profile} ecs execute-command \
            --cluster ${cluster_arn} \
            --task ${task_id} \
            --container ${container_name} \
            --interactive \
            --command "/bin/sh" 2>/dev/null; then

            echo ""
            echo "❌ ECS Exec接続に失敗しました。"
            echo ""
            echo "考えられる原因："
            echo "• タスクでECS Execが無効になっている"
            echo "• Session Manager Pluginがインストールされていない"
            echo "• IAMロールに必要な権限がない"
            echo "• ネットワーク設定に問題がある"
            echo ""
            echo "解決方法："
            echo "1. タスクを --enable-execute-command で再起動"
            echo "2. Session Manager Plugin をインストール"
            echo "3. IAMロールに ssmmessages:* 権限を追加"
            return 1
        fi
    fi
}

# AWS CloudWatch ログ閲覧 (fzf版)
function awslogs() {
    # .aws/credentialsからprofile一覧を取得
    local profile=$(awk '/^\[/{gsub(/\[|\]/, ""); print}' ~/.aws/credentials | fzf --prompt="AWS Profile> " --height=40% --reverse)

    if [[ -z "$profile" ]]; then
        echo "profileが選択されませんでした。"
        return 1
    fi

    echo "Profile: $profile を使用します"

    # 選択されたprofileでロググループ一覧を取得
    local log_group_name=$(aws --profile ${profile} logs describe-log-groups \
        --query 'logGroups[].[logGroupName,retentionInDays,storedBytes]' \
        --output text | \
        awk '{
            retention = ($2 == "None" || $2 == "") ? "無期限" : $2"日";
            size_mb = $3 > 0 ? sprintf("%.1fMB", $3/1024/1024) : "0MB";
            printf "%-50s [保持:%s, サイズ:%s]\n", $1, retention, size_mb
        }' | \
        fzf --prompt="Log Group> " --height=40% --reverse --header="Log Group Name                                   [Retention, Size]")

    if [[ -z "$log_group_name" ]]; then
        echo "ロググループが選択されませんでした。"
        return 1
    fi

    # ロググループ名だけを抽出（フォーマット情報を除去）
    local clean_log_group_name=$(echo $log_group_name | awk '{print $1}')
    echo "Log Group: $clean_log_group_name のログを表示します"

    # オプション選択（tail or 範囲指定）
    local action=$(echo -e "リアルタイム表示 (--follow)\n過去1時間のログ\n過去24時間のログ\n指定時間範囲のログ" | \
        fzf --prompt="表示方法> " --height=40% --reverse)

    case "$action" in
        "リアルタイム表示 (--follow)")
            echo "リアルタイムでログを表示します (Ctrl+Cで終了)"
            aws --profile ${profile} logs tail ${clean_log_group_name} --follow
            ;;
        "過去1時間のログ")
            echo "過去1時間のログを表示します"
            aws --profile ${profile} logs tail ${clean_log_group_name} --since 1h
            ;;
        "過去24時間のログ")
            echo "過去24時間のログを表示します"
            aws --profile ${profile} logs tail ${clean_log_group_name} --since 24h
            ;;
        "指定時間範囲のログ")
            echo "開始時間を入力してください (例: 2024-01-01T10:00:00):"
            read start_time
            echo "終了時間を入力してください (例: 2024-01-01T12:00:00):"
            read end_time
            if [[ -n "$start_time" && -n "$end_time" ]]; then
                echo "指定された時間範囲のログを表示します"
                aws --profile ${profile} logs tail ${clean_log_group_name} --since "${start_time}" --until "${end_time}"
            else
                echo "時間範囲が正しく指定されませんでした。"
                return 1
            fi
            ;;
        *)
            echo "操作がキャンセルされました。"
            return 1
            ;;
    esac
}