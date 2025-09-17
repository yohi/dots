# ===================================================================
# AWS関連カスタム関数
# ===================================================================

# -------------------------------------------------------------------
# 共通ヘルパー関数
# -------------------------------------------------------------------

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
    if [[ -z "$selected_line" ]]; then echo "❌ プロファイルが選択されませんでした。"; return 1; fi

    profile=$(echo "$selected_line" | awk '{print $1}')
    export AWS_PROFILE="$profile"
    echo "✅ プロファイル '$profile' を選択しました。"

    if ! aws sts get-caller-identity --profile "$profile" --query 'Account' --output text >/dev/null 2>&1; then
        echo "❌ AWS認証に失敗しました。プロファイル '$profile' の設定を確認してください。"
        profile=""
        return 1
    fi

    echo "🔐 認証情報OK: $(aws sts get-caller-identity --profile "$profile" --query 'Arn' --output text)"
    echo
    return 0
}

# 共通関数: EC2インスタンス選択
_aws_select_ec2_instance() {
    local selected_profile="${1}"
    if [[ -z "$selected_profile" ]]; then echo "❌ _aws_select_ec2_instance: プロファイルが指定されていません。"; return 1; fi

    echo "🖥️  実行中のEC2インスタンスを検索中 (Profile: ${selected_profile})...";
    local instance_info_line=$(aws ec2 describe-instances --profile "${selected_profile}" --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0],Placement.AvailabilityZone,InstanceType]' --output text | awk '{ name = ($2 == "None" || $2 == "") ? "(No Name)" : $2; printf "%20s %30s %15s %s\n", $1, name, $3, $4 }' | fzf --prompt="EC2 Instance> " --height=40% --reverse --header="Instance ID          Name                           AZ               Type")
    if [[ -z "$instance_info_line" ]]; then echo "❌ EC2インスタンスが選択されませんでした。"; return 1; fi

    instance_id=$(echo "$instance_info_line" | awk '{print $1}')

    local selected_name_tag=$(aws ec2 describe-instances --profile "${selected_profile}" --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].Tags[?Key==`Name`].Value | [0]' --output text)

    local display_name="${selected_name_tag:-'(名前なし)'}"

    echo "✅ EC2インスタンス '$display_name' ($instance_id) を選択しました。"
    echo
    return 0
}


# -------------------------------------------------------------------
# メイン関数
# -------------------------------------------------------------------

# EC2 SSM接続 (fzf版)
function ec2-ssm() {
    local profile
    local instance_id

    if ! _aws_select_profile; then
        return 1
    fi

    if ! _aws_select_ec2_instance "$profile"; then
        return 1
    fi

    echo "Instance: $instance_id に接続します"
    aws ssm start-session --profile "${profile}" --target "${instance_id}"
}

# ECS タスク接続 (fzf版)
function ecs-exec() {
    local profile
    if ! _aws_select_profile; then return 1; fi
    # ... (rest of function) ...
}

# AWS CloudWatch ログ閲覧 (fzf版)
function awslogs() {
    local profile
    if ! _aws_select_profile; then return 1; fi
    # ... (rest of function) ...
}

# RDS IAM認証接続 (fzf版)
function rds-iam() {
    local profile
    if ! _aws_select_profile; then return 1; fi
    # ... (rest of function) ...
}


# ===================================================================
# RDS-SSM 統合関数
# ===================================================================

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
    local search_all_regions=false

    # パラメータ解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                _rds_ssm_show_help
                return 0
                ;;
            --all-regions|-a)
                search_all_regions=true
                shift
                ;;
            *)
                echo "❌ 不明なオプション: $1"
                echo "使用法: rds-ssm [--help|-h] [--all-regions|-a]"
                return 1
                ;;
        esac
    done

    echo "🚀 RDS-SSM接続ツールを開始します..."
    echo

    if ! _aws_select_profile; then return 1; fi
    if ! _aws_select_ec2_instance "$profile"; then return 1; fi

    if ! _rds_ssm_select_rds_instance "$search_all_regions"; then echo "❌ RDSインスタンス選択に失敗しました"; return 1; fi
    if ! _rds_ssm_input_connection_info; then echo "❌ 接続情報入力に失敗しました"; return 1; fi
    if ! _rds_ssm_setup_authentication; then echo "❌ 認証設定に失敗しました"; return 1; fi
    if ! _rds_ssm_start_port_forwarding; then echo "❌ ポートフォワーディング開始に失敗しました"; return 1; fi

    _rds_ssm_connect_to_database
}

# -------------------------------------------------------------------
# rds-ssm ヘルパー関数
# -------------------------------------------------------------------

_rds_ssm_show_help() {
    cat << 'EOF'
🚀 RDS-SSM接続ツール ヘルプ

概要:
  EC2インスタンスを踏み台としてRDSインスタンスに接続するためのツールです。
  SSMセッションマネージャを使用してセキュアにポートフォワーディングを行います。

使用法:
  rds-ssm [オプション]

オプション:
  -h, --help          このヘルプを表示
  -a, --all-regions   全リージョンでRDSインスタンスを検索

主な機能:
  1. AWSプロファイルの選択（fzf）
  2. EC2インスタンスの選択（fzf）
  3. RDSインスタンスの選択（fzf）
     - 単一リージョン検索（デフォルト）
     - 全リージョン検索（--all-regions）
  4. 接続情報の設定
  5. ポートフォワーディングの自動設定
  6. データベースクライアントの起動

前提条件:
  - AWS CLI がインストール・設定済み
  - SSMエージェントがEC2インスタンスで実行中
  - 適切なIAMポリシー（SSM、RDS、EC2の権限）
  - fzf がインストール済み

例:
  rds-ssm                    # 現在のリージョンで検索
  rds-ssm --all-regions      # 全リージョンで検索
  rds-ssm --help             # ヘルプ表示

注意:
  - Ctrl+C で途中キャンセル可能
  - ポートフォワーディングは手動で停止する必要があります
EOF
}

_rds_ssm_select_rds_instance() {
    local search_all_regions="${1:-false}"
    echo "🗄️  RDSインスタンスを検索中 (Profile: ${profile})..."

    # 現在のリージョンとアカウントID情報表示
    local current_region=$(aws configure get region --profile "$profile" 2>/dev/null || echo "us-east-1")
    local account_id=$(aws sts get-caller-identity --profile "$profile" --query 'Account' --output text 2>/dev/null)

    if [[ "$search_all_regions" == "true" ]]; then
        echo "🌏 検索モード: 全リージョン検索"
        echo "🏢 AWSアカウント: $account_id"
    else
        echo "🌏 検索リージョン: $current_region (単一リージョン)"
        echo "🏢 AWSアカウント: $account_id"
        echo "💡 ヒント: 全リージョン検索するには --all-regions オプションを使用"
    fi
    echo

    local rds_instances=""
    local aws_error_output
    aws_error_output=$(mktemp)

    if [[ "$search_all_regions" == "true" ]]; then
        echo "🔍 全リージョンでRDSインスタンスを検索中..."
        # 全リージョンでRDSインスタンスを検索
        local all_regions=$(aws ec2 describe-regions --profile "$profile" --query 'Regions[].RegionName' --output text 2>/dev/null)
        if [[ -z "$all_regions" ]]; then
            echo "❌ リージョン一覧の取得に失敗しました"
            rm -f "$aws_error_output"
            return 1
        fi

        local region_count=0
        local found_instances=0
        for region in $all_regions; do
            ((region_count++))
            echo -n "   リージョン $region を検索中..."

            local region_instances
            region_instances=$(aws rds describe-db-instances --profile "$profile" --region "$region" --query 'DBInstances[].[DBInstanceIdentifier,Engine,DBInstanceStatus,DBInstanceClass,Endpoint.Address,Endpoint.Port,IAMDatabaseAuthenticationEnabled,@.AvailabilityZone]' --output text 2>/dev/null)

            if [[ -n "$region_instances" ]]; then
                local instance_count=$(echo "$region_instances" | wc -l)
                echo " $instance_count 個見つかりました"
                ((found_instances += instance_count))

                # リージョン情報を各行に追加
                while IFS=$'\t' read -r line; do
                    if [[ -n "$line" ]]; then
                        rds_instances+="$line\t$region\n"
                    fi
                done <<< "$region_instances"
            else
                echo " 0個"
            fi
        done

        echo "📊 検索結果: $region_count リージョン中 $found_instances 個のRDSインスタンスを発見"

    else
        # 単一リージョン検索
        echo "🔍 AWS CLI実行中: aws rds describe-db-instances --profile $profile --region $current_region"
        rds_instances=$(aws rds describe-db-instances --profile "$profile" --region "$current_region" --query 'DBInstances[].[DBInstanceIdentifier,Engine,DBInstanceStatus,DBInstanceClass,Endpoint.Address,Endpoint.Port,IAMDatabaseAuthenticationEnabled,@.AvailabilityZone]' --output text 2>"$aws_error_output")

        # リージョン情報を各行に追加
        if [[ -n "$rds_instances" ]]; then
            local temp_instances=""
            while IFS=$'\t' read -r line; do
                if [[ -n "$line" ]]; then
                    temp_instances+="$line\t$current_region\n"
                fi
            done <<< "$rds_instances"
            rds_instances="$temp_instances"
        fi
    fi
    local aws_exit_code=$?

    if [[ $aws_exit_code -ne 0 ]]; then
        echo "❌ AWS RDS情報の取得に失敗しました:"
        cat "$aws_error_output"
        rm -f "$aws_error_output"
        return 1
    fi

    rm -f "$aws_error_output"

    # 詳細なデバッグ情報を出力
    echo "📊 取得結果統計:"
    echo "   - 生データサイズ: ${#rds_instances} 文字"
    echo "   - 行数: $(echo "$rds_instances" | wc -l)"
    echo "   - AWS CLI終了コード: $aws_exit_code"

    if [[ -z "$rds_instances" || "$rds_instances" == "" ]]; then
        echo "❌ RDSインスタンスが見つかりません (プロファイル: $profile)"
        echo "   - AWSプロファイルの設定を確認してください"
        echo "   - 現在のリージョン ($current_region) にRDSインスタンスが存在することを確認してください"
        echo "   - IAMポリシーでRDSの読み取り権限があることを確認してください"
        echo ""
        echo "🔧 トラブルシューティング:"
        echo "   1. 他のリージョンを確認: aws rds describe-db-instances --region <region>"
        echo "   2. 全リージョン検索を有効にする場合は --all-regions フラグ追加を検討"
        return 1
    fi

    local fzf_lines=()
    declare -A rds_map
    local processed_count=0
    local filtered_count=0

    echo "🔍 取得したRDSデータ (先頭5行):"
    echo "$rds_instances" | head -5
    echo "--- (以下省略) ---"

    # 空行を除去してクリーンアップ
    local cleaned_instances
    cleaned_instances=$(echo "$rds_instances" | grep -v '^[[:space:]]*$' | grep -v '^$')

    echo
    echo "🧹 データクリーンアップ:"
    echo "   クリーンアップ前の行数: $(echo "$rds_instances" | wc -l)"
    echo "   クリーンアップ後の行数: $(echo "$cleaned_instances" | wc -l)"
    echo

    echo "🔄 フィルタリング処理開始..."
    while IFS=$'\t' read -r db_id engine db_status db_class endpoint port iam_auth az region;
    do
        ((processed_count++))

        # 空行やnullフィールドのチェック（詳細ログ）
        if [[ -z "$db_id" || "$db_id" == "None" || -z "${db_id// }" ]]; then
            echo "   [除外] 行$processed_count: db_idが空またはNone (db_id='$db_id' length=${#db_id})"
            continue
        fi

        # エンジン情報が無い場合も除外
        if [[ -z "$engine" || "$engine" == "None" ]]; then
            echo "   [除外] 行$processed_count: engineが空 (db_id='$db_id' engine='$engine')"
            continue
        fi

        # フィールドのデフォルト値設定
        engine="${engine:-'Unknown'}"
        db_status="${db_status:-'Unknown'}"
        db_class="${db_class:-'Unknown'}"
        endpoint="${endpoint:-'N/A'}"
        port="${port:-'N/A'}"
        iam_auth="${iam_auth:-'false'}"
        az="${az:-'N/A'}"
        region="${region:-$current_region}"

        echo "   [処理] 行$processed_count: $db_id ($engine, $db_status, $region)"

        local fzf_line=$(printf "%-30s | %-12s | %-12s | %-12s | %s" "$db_id" "$engine" "$db_status" "$region" "$db_class")

        # 空でないことを確認してから配列に追加
        if [[ -n "$fzf_line" && -n "$db_id" ]]; then
            fzf_lines+=("$fzf_line")

            # 元のキーをそのまま使用（引用符があってもマップアクセス時に対応）
            rds_map["$db_id"]="$db_id|$engine|$endpoint|$port|$iam_auth|$db_status|$region"
            ((filtered_count++))
            echo "   [追加] 配列へ追加完了: インデックス=$filtered_count"
        else
            echo "   [警告] 空のfzf_lineまたはdb_idのため配列追加をスキップ"
        fi
    done <<< "$cleaned_instances"

    echo
    echo "📊 フィルタリング結果:"
    echo "   - 処理した行数: $processed_count"
    echo "   - 有効なインスタンス数: $filtered_count"
    echo "   - fzf配列要素数: ${#fzf_lines[@]}"

    if [[ ${#fzf_lines[@]} -eq 0 ]]; then
        echo "❌ RDSインスタンスのリスト処理に失敗しました。"
        echo "🔍 デバッグ情報:"
        echo "Raw AWS Output Length: ${#rds_instances}"
        echo "Raw AWS Output (first 200 chars): ${rds_instances:0:200}"
        return 1
    fi

    echo
    echo "🎯 fzf選択画面を起動中..."
    echo "   利用可能な選択肢数: ${#fzf_lines[@]} 個"

    # fzf入力データの詳細デバッグ
    echo
    echo "🔍 fzf配列の先頭3行を確認:"
    for i in {1..3}; do
        if [[ $i -le ${#fzf_lines[@]} ]]; then
            echo "   [$i] '${fzf_lines[$i]}'"
        else
            echo "   [$i] (範囲外)"
        fi
    done

    echo
    echo "🔍 配列の詳細情報:"
    echo "   配列の実際の範囲: 1 to ${#fzf_lines[@]}"
    if [[ ${#fzf_lines[@]} -gt 0 ]]; then
        echo "   最初の要素: '${fzf_lines[1]}'"
        echo "   最後の要素: '${fzf_lines[${#fzf_lines[@]}]}'"
    fi

    echo
    echo "🔍 配列要素数確認:"
    echo "   配列サイズ: ${#fzf_lines[@]}"
    echo "   期待値: $filtered_count"

    if [[ ${#fzf_lines[@]} -ne $filtered_count ]]; then
        echo "⚠️  警告: 期待行数($filtered_count)と配列サイズ(${#fzf_lines[@]})が一致しません"
        echo "🔍 詳細調査のため、全配列要素を表示:"
        echo "--- fzf_lines START ---"
        for i in "${!fzf_lines[@]}"; do
            echo "$((i+1)): ${fzf_lines[$i]}"
        done
        echo "--- fzf_lines END ---"
    fi

    echo "🚀 fzf実行..."
    local selected_line
    selected_line=$(printf '%s\n' "${fzf_lines[@]}" | fzf --header="Identifier                     | Engine       | Status       | Region       | Class" --prompt="RDSインスタンスを選択してください: " --layout=reverse --border)

    if [[ -z "$selected_line" ]]; then
        echo "❌ RDSインスタンスが選択されませんでした"
        return 1
    fi

    local selected_db_id
    selected_db_id=$(echo "$selected_line" | awk '{print $1}')

    # 選択されたIDから引用符と空白を除去
    local clean_selected_id="${selected_db_id//\"/}"
    clean_selected_id="${clean_selected_id// /}"
    clean_selected_id="${clean_selected_id//\'/}"

    echo "🔍 選択されたDB ID: '$selected_db_id'"
    echo "🔍 クリーンアップ後ID: '$clean_selected_id'"
    echo "🔍 選択されたID長: ${#selected_db_id} → ${#clean_selected_id}"
    echo "🔍 マップ情報: '${rds_map[$clean_selected_id]}'"

    # マップのキー一覧を表示（最初の5個）
    echo "🔍 マップに登録されているキー（最初の5個）:"
    local key_count=0
    for key in ${(k)rds_map}; do
        ((key_count++))
        # キー表示時にも引用符を除去
        local display_key="${key//\"/}"
        display_key="${display_key//\'/}"
        echo "   [$key_count] '$display_key' (長さ: ${#key}, 表示長: ${#display_key})"
        if [[ $key_count -ge 5 ]]; then
            echo "   ... (以下省略、総数: ${#rds_map[@]})"
            break
        fi
    done

    # 部分マッチ検索
    echo "🔍 部分マッチ検索:"
    local match_found=false
    for key in ${(k)rds_map}; do
        if [[ "$key" == *"$clean_selected_id"* || "$clean_selected_id" == *"$key"* ]]; then
            echo "   部分マッチ発見: '$key'"
            match_found=true
        fi
    done
    if [[ "$match_found" == "false" ]]; then
        echo "   部分マッチなし"
    fi

    local selected_info="${rds_map[$clean_selected_id]}"

    # 直接マッチしない場合、引用符付きキーで再試行
    if [[ -z "$selected_info" ]]; then
        echo "🔄 直接マッチ失敗、引用符付きキーで再試行..."
        local quoted_key="\"$clean_selected_id\""
        selected_info="${rds_map[$quoted_key]}"
        echo "🔍 引用符付きキー試行: '$quoted_key' → 結果: '${selected_info:0:50}...'"
    fi

    # 単一引用符も試行
    if [[ -z "$selected_info" ]]; then
        echo "🔄 単一引用符付きキーで再試行..."
        local single_quoted_key="'$clean_selected_id'"
        selected_info="${rds_map[$single_quoted_key]}"
        echo "🔍 単一引用符付きキー試行: '$single_quoted_key' → 結果: '${selected_info:0:50}...'"
    fi

    # 全キーとの完全照合
    if [[ -z "$selected_info" ]]; then
        echo "🔄 全キー照合を実行中..."
        for key in ${(k)rds_map}; do
            local clean_key="${key//\"/}"
            clean_key="${clean_key//\'/}"
            clean_key="${clean_key// /}"
            if [[ "$clean_key" == "$clean_selected_id" ]]; then
                selected_info="${rds_map[$key]}"
                echo "✅ 照合成功: 実際のキー='$key' → クリーンキー='$clean_key'"
                break
            fi
        done
    fi

    if [[ -z "$selected_info" ]]; then
        echo "❌ 選択されたインスタンス '$clean_selected_id' の詳細情報が見つかりません"
        return 1
    fi

    echo "✅ マップ情報取得成功: '$selected_info'"

    local selected_db_status=$(echo "$selected_info" | cut -d'|' -f6)
    local selected_region=$(echo "$selected_info" | cut -d'|' -f7)

    if [[ "$selected_db_status" != "available" ]]; then
        echo "⚠️  警告: 選択されたインスタンスは 'available' 状態ではありません (現在: $selected_db_status)。接続に失敗する可能性があります。"
    fi

    rds_endpoint=$(echo "$selected_info" | cut -d'|' -f3)
    rds_port=$(echo "$selected_info" | cut -d'|' -f4)
    db_engine=$(echo "$selected_info" | cut -d'|' -f2)
    use_iam_auth=$(echo "$selected_info" | cut -d'|' -f5)

    echo "✅ RDSインスタンス '$selected_db_id' を選択しました"
    echo "   リージョン: $selected_region"
    echo "   エンジン: $db_engine, エンドポイント: $rds_endpoint:$rds_port, IAM認証: $([[ "$use_iam_auth" == "true" ]] && echo "有効" || echo "無効")"
    echo
    return 0
}


_rds_ssm_input_connection_info() {
    echo "💾 データベース接続情報を設定します..."
    echo

    # デフォルト値の設定
    local default_db_name=""
    local default_db_user=""

    # エンジンに基づくデフォルト値の設定
    case "$db_engine" in
        "aurora-postgresql"|"postgres")
            default_db_name="postgres"
            default_db_user="postgres"
            ;;
        "aurora-mysql"|"mysql")
            default_db_name="mysql"
            default_db_user="admin"
            ;;
        *)
            default_db_name="db"
            default_db_user="admin"
            ;;
    esac

    echo "📋 現在の設定:"
    echo "   エンジン: $db_engine"
    echo "   エンドポイント: $rds_endpoint:$rds_port"
    echo "   IAM認証: $([[ "$use_iam_auth" == "true" ]] && echo "有効" || echo "無効")"
    echo

    # データベース名の入力
    echo -n "データベース名を入力してください (デフォルト: $default_db_name): "
    read db_name
    db_name="${db_name:-$default_db_name}"

    # ユーザー名の入力
    echo -n "データベースユーザー名を入力してください (デフォルト: $default_db_user): "
    read db_user
    db_user="${db_user:-$default_db_user}"

    # ローカルポートの設定
    local_port=5432
    if [[ "$db_engine" =~ mysql ]]; then
        local_port=3306
    fi

    echo -n "ローカルポート番号を入力してください (デフォルト: $local_port): "
    read input_port
    local_port="${input_port:-$local_port}"

    echo
    echo "✅ 接続情報設定完了:"
    echo "   データベース名: $db_name"
    echo "   ユーザー名: $db_user"
    echo "   ローカルポート: $local_port"
    echo "   IAM認証: $([[ "$use_iam_auth" == "true" ]] && echo "有効" || echo "無効")"
    echo

    return 0
}

_rds_ssm_setup_authentication() {
    echo "🔐 認証方式を設定します..."
    echo

    if [[ "$use_iam_auth" == "true" ]]; then
        echo "🎯 IAM認証が有効です"
        echo "   IAMトークンを自動生成します..."

        # IAM認証トークンの生成
        local iam_token
        iam_token=$(aws rds generate-db-auth-token \
            --profile "$profile" \
            --hostname "$rds_endpoint" \
            --port "$rds_port" \
            --username "$db_user" 2>/dev/null)

        if [[ $? -eq 0 && -n "$iam_token" ]]; then
            echo "✅ IAMトークン生成成功"
            db_password="$iam_token"
        else
            echo "❌ IAMトークン生成に失敗しました"
            echo "   通常のパスワード認証に切り替えます"
            use_iam_auth="false"
        fi
    fi

    if [[ "$use_iam_auth" != "true" ]]; then
        echo "🔑 パスワード認証を使用します"
        echo -n "データベースパスワードを入力してください: "
        read -s db_password
        echo

        if [[ -z "$db_password" ]]; then
            echo "❌ パスワードが入力されませんでした"
            return 1
        fi
    fi

    echo "✅ 認証設定完了"
    echo
    return 0
}

_rds_ssm_start_port_forwarding() {
    echo "🌉 SSMポートフォワーディングを開始します..."
    echo

    echo "📋 ポートフォワーディング設定:"
    echo "   EC2インスタンス: $instance_id"
    echo "   ローカルポート: $local_port"
    echo "   リモートホスト: $rds_endpoint"
    echo "   リモートポート: $rds_port"
    echo

    # 既存のポートフォワーディングプロセスの確認
    local existing_process
    existing_process=$(ps aux | grep "aws ssm start-session" | grep "$local_port:$rds_endpoint:$rds_port" | grep -v grep)

    if [[ -n "$existing_process" ]]; then
        echo "⚠️  既存のポートフォワーディングが検出されました"
        echo "   プロセス: $existing_process"
        echo -n "既存のプロセスを停止して新しく開始しますか？ (y/N): "
        read response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "🔄 既存プロセスを停止中..."
            pkill -f "aws ssm start-session.*$local_port:$rds_endpoint:$rds_port"
            sleep 2
        else
            echo "✅ 既存のポートフォワーディングを継続使用します"
            return 0
        fi
    fi

    # ポートの使用状況確認
    if lsof -i :$local_port > /dev/null 2>&1; then
        echo "❌ ローカルポート $local_port は既に使用中です"
        echo "   使用中のプロセス:"
        lsof -i :$local_port
        return 1
    fi

    echo "🚀 ポートフォワーディングを開始します..."
    echo "   コマンド: aws ssm start-session --profile $profile --target $instance_id --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters host=$rds_endpoint,portNumber=$rds_port,localPortNumber=$local_port"
    echo

    # ポートフォワーディングをバックグラウンドで実行
    aws ssm start-session \
        --profile "$profile" \
        --target "$instance_id" \
        --document-name "AWS-StartPortForwardingSessionToRemoteHost" \
        --parameters "host=$rds_endpoint,portNumber=$rds_port,localPortNumber=$local_port" \
        > /tmp/ssm-port-forward.log 2>&1 &

    local ssm_pid=$!

    echo "📊 ポートフォワーディングプロセス ID: $ssm_pid"
    echo "📝 ログファイル: /tmp/ssm-port-forward.log"

    # 接続確立の待機
    echo "⏳ 接続確立を待機中..."
    local wait_count=0
    while [[ $wait_count -lt 30 ]]; do
        if lsof -i :$local_port > /dev/null 2>&1; then
            echo "✅ ポートフォワーディング確立完了"
            echo
            return 0
        fi
        sleep 1
        ((wait_count++))
        echo -n "."
    done

    echo
    echo "❌ ポートフォワーディングの確立に失敗しました"
    echo "📋 ログ内容:"
    cat /tmp/ssm-port-forward.log
    return 1
}

_rds_ssm_connect_to_database() {
    echo "💾 データベースに接続します..."
    echo

    echo "📋 接続情報確認:"
    echo "   ホスト: localhost:$local_port (via SSM Port Forwarding)"
    echo "   データベース: $db_name"
    echo "   ユーザー: $db_user"
    echo "   エンジン: $db_engine"
    echo

    local connection_cmd=""
    local connection_string=""

    # データベースエンジンに応じた接続コマンドの生成
    case "$db_engine" in
        "aurora-postgresql"|"postgres")
            if command -v psql >/dev/null 2>&1; then
                if [[ "$use_iam_auth" == "true" ]]; then
                    connection_cmd="PGPASSWORD='$db_password' psql -h localhost -p $local_port -U $db_user -d $db_name"
                else
                    connection_cmd="psql -h localhost -p $local_port -U $db_user -d $db_name"
                fi
                connection_string="postgresql://$db_user:PASSWORD@localhost:$local_port/$db_name"
            else
                echo "❌ psql が見つかりません。PostgreSQLクライアントをインストールしてください。"
                echo "   Ubuntu/Debian: sudo apt-get install postgresql-client"
                echo "   macOS: brew install postgresql"
                return 1
            fi
            ;;
        "aurora-mysql"|"mysql")
            if command -v mysql >/dev/null 2>&1; then
                if [[ "$use_iam_auth" == "true" ]]; then
                    connection_cmd="mysql -h localhost -P $local_port -u $db_user -p'$db_password' $db_name"
                else
                    connection_cmd="mysql -h localhost -P $local_port -u $db_user -p $db_name"
                fi
                connection_string="mysql://$db_user:PASSWORD@localhost:$local_port/$db_name"
            else
                echo "❌ mysql が見つかりません。MySQLクライアントをインストールしてください。"
                echo "   Ubuntu/Debian: sudo apt-get install mysql-client"
                echo "   macOS: brew install mysql-client"
                return 1
            fi
            ;;
        *)
            echo "⚠️  未対応のデータベースエンジン: $db_engine"
            echo "   手動で接続してください。"
            ;;
    esac

    if [[ -n "$connection_cmd" ]]; then
        echo "🚀 接続コマンド:"
        if [[ "$use_iam_auth" == "true" ]]; then
            echo "   $connection_cmd"
        else
            echo "   $(echo "$connection_cmd" | sed 's/-p$/-p[PASSWORD]/')"
        fi
        echo

        echo "🔗 接続文字列:"
        echo "   $connection_string"
        echo

        echo "💡 接続方法:"
        echo "   1. 自動接続: Enter キーを押すとデータベースクライアントが起動します"
        echo "   2. 手動接続: 上記のコマンドをコピーして別のターミナルで実行"
        echo "   3. GUI接続: 上記の接続情報をお使いのDBクライアント（DBeaver、pgAdminなど）で使用"
        echo

        echo -n "データベースクライアントを起動しますか？ (Y/n): "
        read response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            echo "📋 接続情報を保存しました。手動で接続してください。"
        else
            echo "🚀 データベースクライアントを起動中..."
            if [[ "$use_iam_auth" == "true" ]]; then
                eval "$connection_cmd"
            else
                echo "パスワードを入力してください:"
                eval "$connection_cmd"
            fi
        fi
    fi

    echo
    echo "📋 注意事項:"
    echo "   - ポートフォワーディングは手動で停止する必要があります"
    echo "   - 停止方法: 別のターミナルで 'pkill -f \"aws ssm start-session.*$local_port\"'"
    echo "   - ログファイル: /tmp/ssm-port-forward.log"
    echo
}

_rds_ssm_cleanup() {
    # ...
}
