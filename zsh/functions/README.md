# Zsh Functions

このディレクトリには、カスタムZsh関数が含まれています。

## 利用可能な関数

### 🔧 rds-ssm - RDS-SSM接続ツール

SSM Session Manager経由でRDSインスタンスに安全に接続するための統合ツールです。

#### 特徴

- ✅ **AWS プロファイル選択**: 設定された複数のAWSプロファイルから選択
- ✅ **SSM対応EC2自動検出**: SSM Agent有効なEC2インスタンスの自動検出・選択
- ✅ **RDSインスタンス一覧**: 利用可能なRDSインスタンスの表示・選択
- ✅ **IAM認証自動判定**: RDSのIAM認証対応状況を自動判定
- ✅ **認証トークン自動生成**: IAM認証時の認証トークン自動生成
- ✅ **安全なパスワード入力**: パスワード認証時の隠し文字入力
- ✅ **SSMポートフォワーディング**: 安全なSSMトンネル経由接続
- ✅ **MySQL/PostgreSQL対応**: 主要データベースエンジン対応
- ✅ **自動クリーンアップ**: 接続終了時の自動リソース解放

#### 使用方法

```bash
# 基本的な使用方法
rds-ssm

# ヘルプ表示
rds-ssm --help
```

#### 必要な前提条件

##### ツール要件
- `aws-cli` (v2) - AWS CLI
- `session-manager-plugin` - AWS Session Manager Plugin
- `mysql` または `psql` - データベースクライアント
- `nc` (netcat) - ネットワーク接続確認用
- `lsof` - ポート使用状況確認用

##### AWS要件
- **AWSプロファイル設定**: `aws configure` でプロファイル設定済み
- **IAM権限**: 以下の権限が必要
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ssm:StartSession",
          "ssm:DescribeInstanceInformation",
          "ec2:DescribeInstances",
          "rds:DescribeDBInstances",
          "rds:GenerateDataKeyWithoutPlaintext"
        ],
        "Resource": "*"
      }
    ]
  }
  ```

##### EC2要件
- **SSM Agent**: EC2インスタンスにSSM Agentがインストール済み
- **IAMロール**: EC2インスタンスに以下のポリシーがアタッチされたIAMロール
  - `AmazonSSMManagedInstanceCore`
  - カスタムRDSアクセスポリシー (必要に応じて)
- **ネットワークアクセス**: EC2からRDSへのネットワーク接続が可能

##### RDS要件
- **ネットワーク設定**: EC2からRDSへのアクセスが可能なセキュリティグループ設定
- **IAM認証設定** (オプション): IAM認証を使用する場合
  - RDSインスタンスでIAM認証が有効
  - データベースユーザーがIAM認証用に作成済み

#### 対話式設定フロー

1. **AWS Profile選択**
   - 利用可能なAWSプロファイル一覧表示
   - 現在のプロファイル・デフォルトプロファイルの表示
   - 選択したプロファイルの認証情報確認

2. **EC2インスタンス選択**
   - SSM接続可能なEC2インスタンス自動検出
   - インスタンス詳細情報表示 (名前、ID、タイプ、IP等)
   - SSM接続テスト実行

3. **RDSインスタンス選択**
   - 利用可能なRDSインスタンス一覧表示
   - データベースエンジン・バージョン情報表示
   - IAM認証対応状況の表示

4. **接続情報入力**
   - データベース名入力
   - ユーザー名入力
   - ローカルポート番号設定 (自動設定 or カスタム)

5. **認証設定**
   - **IAM認証**: 自動でトークン生成 (15分間有効)
   - **パスワード認証**: 安全な隠し文字入力

6. **接続確立**
   - SSMポートフォワーディング開始
   - 接続確認とテスト
   - データベースクライアント起動

#### エラー対応

##### よくある問題と解決策

| エラー | 原因 | 解決策 |
|--------|------|--------|
| `AWSプロファイルが見つかりません` | AWS CLIが未設定 | `aws configure` でプロファイル設定 |
| `SSM接続可能なEC2インスタンスが見つかりません` | SSM Agent未インストール/未起動 | EC2にSSM Agentインストール・IAMロール設定 |
| `IAM認証トークンの生成に失敗しました` | RDS接続権限不足 | IAMユーザー/ロールに`rds-db:connect`権限追加 |
| `ポートフォワーディング接続がタイムアウトしました` | ネットワーク接続問題 | EC2-RDS間のセキュリティグループ設定確認 |
| `MySQLクライアントがインストールされていません` | DB クライアント未インストール | `sudo apt-get install mysql-client postgresql-client` |

#### セキュリティ考慮事項

- 🔐 **認証トークン**: IAM認証トークンは15分間で自動失効
- 🔑 **パスワード保護**: パスワードは隠し文字入力、メモリ上のみ保持
- 🔗 **暗号化通信**: SSM Session Manager経由の暗号化されたトンネル使用
- 🧹 **自動クリーンアップ**: 接続終了時の認証情報・セッション自動削除
- 📝 **ログ管理**: 最小限のログ出力、機密情報は記録しない

#### パフォーマンス

- ⚡ **高速検索**: AWS API並列呼び出しによる高速データ取得
- 💾 **省メモリ**: 必要最小限のデータのみメモリ保持
- 🔄 **自動リトライ**: ネットワーク問題時の自動再試行機能
- ⏱️ **タイムアウト制御**: 適切なタイムアウト設定による応答性確保

#### トラブルシューティング

##### デバッグモード
```bash
# デバッグ情報を有効にして実行
export AWS_CLI_DEBUG=1
rds-ssm
```

##### ログ確認
```bash
# SSMセッションログ確認
tail -f /tmp/rds-ssm-session.log

# AWS CLI ログ確認
aws logs describe-log-groups --profile YOUR_PROFILE
```

##### 手動接続確認
```bash
# SSM接続テスト
aws ssm start-session --target i-xxxxxxxxx --profile YOUR_PROFILE

# RDS接続テスト (ポートフォワーディング後)
nc -zv localhost 13306
```

#### ライセンス

このスクリプトはMITライセンスの下で提供されています。

### 🌐 aws.zsh - AWS関連ユーティリティ

AWS操作に関する便利な関数を提供します。

#### 主な機能

- **ec2-ssm**: EC2インスタンスにSSM経由で接続
- **ecs-exec**: ECSタスクにECS Exec経由で接続
- **awslogs**: CloudWatch Logsの表示
- **rds-iam**: RDS IAM認証トークンの生成
- **aws-help**: AWS関数の一覧とヘルプ表示

#### 使用例

```bash
# EC2インスタンス接続
ec2-ssm

# ECSタスク接続
ecs-exec

# CloudWatch Logs表示
awslogs

# RDS IAM認証トークン生成
rds-iam

# AWS関数ヘルプ
aws-help
```

#### 前提条件

- AWS CLI v2
- AWS Session Manager Plugin
- fzf (fuzzy finder)
- 適切なIAM権限

### 🖱️ cursor.zsh - Cursor IDE連携

Cursor IDEとの連携機能を提供します。

#### 主な機能

- プロジェクト自動起動
- 設定ファイル管理
- 拡張機能管理

## インストール

これらの関数は、`zshrc`で自動的に読み込まれます。

```bash
# .zshrcの関連セクション
# Functions auto-loading
for func_file in ~/.dotfiles/zsh/functions/*.zsh; do
    [ -r "$func_file" ] && source "$func_file"
done
```

## 関数の追加

新しい関数を追加する場合:

1. `{function_name}.zsh` ファイルを作成
2. 関数を定義
3. 必要に応じてREADMEを更新
4. zshを再起動またはsourceで読み込み

```bash
# 新しい関数の即座読み込み
source ~/.dotfiles/zsh/functions/{function_name}.zsh
```
