# Oh My OpenCodeにおけるgit-masterスキルのための高度な権限委譲とセキュリティ構成に関する包括的レポート

## 1. 序論：自律型開発エージェントにおける権限管理のパラダイムシフト

現代のソフトウェアエンジニアリングにおいて、AIエージェントは単なるコード補完ツールから、複雑なタスクを自律的に遂行する「デジタル社員」へと進化を遂げている。特に、**OpenCode** プラットフォーム上で動作する **Oh My OpenCode** フレームワークは、複数の専門エージェント（Sisyphus, Prometheus, Oracleなど）を協調させ、大規模なリファクタリングや機能実装を遂行する能力を持つ[1]。このエコシステムの中で、バージョン管理操作を専門とする **git-master スキル** は、アトミックなコミットの生成、履歴の調査（blame, bisect）、そしてリベースやスカッシュといった高度なGit操作を担う中核的なコンポーネントである[3]。

しかし、この自律性を最大限に発揮させる上で最大の障壁となるのが、セキュリティのための「人間による承認（Human-in-the-Loop）」プロセスである。デフォルトのOpenCode構成では、ファイルシステムの変更やシェルコマンドの実行（特にgitコマンド）に対して、ユーザーによる明示的な承認が都度求められる[3]。git-master スキルが推奨する「アトミックコミット」の実践——すなわち、論理的な変更単位ごとに細かくコミットを分割する作業——においては、数十回のコマンド実行が発生するため、この承認プロセスがボトルネックとなり、エージェントの自律性を著しく損なう結果となる[4]。

本レポートは、セキュリティリスクを最小限に抑えつつ、git-master スキルによるGit操作に対してのみ「ほぼフル権限（almost full open）」を付与するための技術的アプローチ、構成戦略、および実装詳細を網羅的に解説するものである。ここでは、単なる設定変更の羅列ではなく、Oh My OpenCodeの内部アーキテクチャ、権限評価ロジック、エージェントの委譲モデルに基づいた、堅牢かつスケーラブルなソリューションを提案する。

## 2. アーキテクチャ分析：OpenCodeとOh My OpenCodeの権限モデル

適切なソリューションを設計するためには、まずシステムがどのようにツール実行リクエストを評価し、承認フローをトリガーしているかを深く理解する必要がある。

### 2.1 権限評価のレイヤー構造

OpenCodeおよびOh My OpenCode環境におけるツール実行権限は、以下の多層的なレイヤーで評価される。

1. **ハードウェア/OSレベルのサンドボックス**: コンテナ化（Docker）やOSのユーザー権限による制約[5]。
2. **OpenCodeコアのセーフティネット**: システムにとって致命的なコマンドのブラックリスト。
3. **グローバル設定 (opencode.json)**: ユーザーまたはプロジェクト全体に適用されるデフォルトの権限ポリシー[7]。
4. **プラグイン/フレームワーク設定 (oh-my-opencode.json)**: エージェントごとの微細な権限オーバーライドや、特定のツールに対するパターンマッチング[3]。
5. **ランタイムフック**: 実行直前に介入する動的なスクリプト（PermissionRequestフックなど）[9]。

git-master スキルが git commit を発行しようとする際、このリクエストは通常、**bash ツール** への呼び出しとして処理される[4]。したがって、「Gitの権限を開放する」という課題は、技術的には「bash ツールの特定の引数パターンに対して、特定のコンテキスト（エージェント/スキル）でのみ承認をバイパスする」という問題に帰着される。

### 2.2 git-master スキルの動作特性

git-master は、MCP（Model Context Protocol）サーバーを経由する playwright スキルとは異なり、システム標準の git バイナリを直接 bash ツール経由で操作する「ラッパースキル」である[4]。

| 特性 | 詳細 | 権限設定への影響 |
| :---- | :---- | :---- |
| **実行ツール** | bash | git 専用のMCPではなく、汎用シェルの権限管理が必要となる。 |
| **操作頻度** | 極めて高い | status, diff, add, commit のサイクルを高速で繰り返すため、完全な自動化が必須。 |
| **リスクプロファイル** | 混合 | log や status は無害だが、push --force や reset --hard は破壊的である。 |
| **実行コンテキスト** | 委譲タスク | 多くの場合、メインエージェント（Sisyphus）からサブタスクとして呼び出される[3]。 |

この特性から、単に bash 全体を allow に設定することは、`rm -rf /` のような破壊的操作も許可することになるため、セキュリティ上の自殺行為に等しい。求められるのは、**コマンドパターン** と **エージェントアイデンティティ** に基づく精密な制御である。

## 3. コアソリューション：パターンマッチングによる詳細権限設定

最も推奨されるアプローチは、`oh-my-opencode.json` の設定ファイル内で利用可能な、bash ツールに対する**コマンド単位のパターンマッチング機能**を活用することである。この機能により、正規表現やグロブパターンを用いて、許可するコマンドをホワイトリスト形式で定義できる[3]。

### 3.1 設定ファイルの構造と優先順位

設定は以下のパスにあるJSONファイル（JSONC形式をサポート）で行う。プロジェクト固有の設定はユーザー設定よりも優先されるため、リポジトリごとに異なるセキュリティポリシーを適用可能である[3]。

* **プロジェクト設定**: `.opencode/oh-my-opencode.json` （推奨）
* **ユーザー設定**: `~/.config/opencode/oh-my-opencode.json`

### 3.2 基本的な実装：git * パターンの適用

git-master スキルが発行するあらゆるGitコマンドを無条件で許可する場合の最小構成は以下の通りである。ここでは、メインのオーケストレーターである Sisyphus エージェントに対して設定を適用する例を示す。

```json
{
  "$schema": "[https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json](https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json)",
  "agents": {
    "Sisyphus": {
      "permission": {
        "bash": {
          // Gitコマンドであれば、引数に関わらず全て許可する
          "git *": "allow",
          // その他のBashコマンドは安全のため確認を求める（またはdeny）
          "*": "ask"
        }
      }
    }
  }
}
```

この設定における `"git *"` は、git で始まり、その後に任意の引数が続くコマンド文字列にマッチする[5]。これにより、`git commit`, `git push`, `git log` などは全て自動承認され、`npm install` や `ls -la` などはユーザー確認フローへと回される。

### 3.3 セキュリティを考慮した「ほぼフル開放」構成

「フル開放」と言えども、`git push --force` によるリモートリポジトリの破壊や、`git clean -fdx` による未追跡ファイルの誤削除といった事故は防ぐべきである。Oh My OpenCodeの権限評価エンジンは、より具体的なパターンを優先するか、あるいは記述順序によって評価を行う（実装依存だが、通常は特異性の高いルールを優先するか、後勝ちのルールが適用される）[5]。

以下の構成は、日常的な作業（コミット、プッシュ、ブランチ操作）をフルオートにしつつ、破壊的な操作のみ「確認（ask）」または「拒否（deny）」する、実運用に即したベストプラクティスである。

**推奨構成：セキュア・オートメーション・プロファイル**

```json
{
  "agents": {
    "Sisyphus": {
      "permission": {
        "bash": {
          // --- 安全な参照系操作（完全自動化） ---
          "git status": "allow",
          "git log *": "allow",
          "git diff *": "allow",
          "git show *": "allow",
          "git blame *": "allow",
          "git branch": "allow",
          "git branch -a": "allow",

          // --- 作業の進行に必要な変更操作（完全自動化） ---
          "git add *": "allow",
          "git commit *": "allow",
          "git checkout *": "allow",
          "git switch *": "allow",
          "git merge *": "allow",
          "git stash": "allow",
          "git stash pop": "allow",
            
          // --- リモート同期（通常操作は許可） ---
          "git fetch *": "allow",
          "git pull *": "allow",
          "git push": "allow",
          "git push origin *": "allow",

          // --- 【重要】破壊的操作のガードレール ---
          // 強制プッシュは絶対に確認を求めるか、禁止する
          "git push --force": "deny",
          "git push -f": "deny",
          "git push * --force": "deny",
            
          // 履歴の書き換え（Rebase/Reset）はリスクが高いため確認を挟む
          // ※熟練ユーザーで完全に任せる場合は "allow" に変更可
          "git rebase *": "ask",
          "git reset *": "ask",
            
          // 未追跡ファイルの削除は環境設定を消す恐れがあるため確認
          "git clean *": "ask",

          // --- デフォルトフォールバック ---
          // 上記以外のGitコマンド（将来的なサブコマンドなど）は許可
          "git *": "allow",
            
          // Git以外は全て確認
          "*": "ask"
        }
      }
    }
  }
}
```

この構成により、git-master スキルはユーザーの介入なしにコードの保存と整理を行うことができ、かつ「AIが誤ってmainブランチを破壊する」という最悪のシナリオをシステムレベルで防ぐことが可能になる。

## 4. アプローチの深化：エージェント分離による権限の局所化

前述の設定は Sisyphus エージェント全体に適用されるため、Sisyphusが文脈的にGit以外の目的（例：シェルスクリプトの生成と実行のテストなど）で git コマンドを発行する場合も許可されてしまう。より厳密に「git-master スキルの使用時のみ」権限を与えたい場合、Oh My OpenCodeの**タスク委譲（Delegation）メカニズム**を利用したエージェント分離戦略が有効である。

### 4.1 タスク委譲とエージェントのマッピング

Oh My OpenCodeのドキュメントでは、git-master スキルを使用する際、コンテキストを節約するために `task(category='quick', load_skills=['git-master'])` を使用することが強く推奨されている[3]。この `category='quick'` で指定されたタスクは、設定ファイル内の `categories` マッピングに基づいて、特定のモデルやエージェント設定で実行されるサブエージェント（Sub-agent）によって処理される。

つまり、quick カテゴリを担当するエージェントに対してのみGitの特権を与えれば、メインの Sisyphus エージェントの権限を絞ったまま、Git操作時のみ権限を昇格させる「特権分離（Privilege Separation）」が実現できる。

### 4.2 特化型「Git Ops」エージェントの構成

以下の手順で、Git操作専用の権限を持つエージェント構成を作成する。

1. **専用エージェントの定義**: `oh-my-opencode.json` 内で、Git操作に特化した権限を持つエージェント設定をオーバーライドまたは新規定義する。多くの場合、quick カテゴリはデフォルトで軽量モデル（Haikuなど）にマッピングされているが、これを明示的に構成する[3]。
2. **カテゴリとの紐付け**: `quick` カテゴリがそのエージェントを使用するように設定する。

```json
{
  "agents": {
    // Git操作を担当させる "GitOps-Agent" を定義（既存のexploreなどを流用しても良い）
    "git-specialist": {
      "description": "Git operations specialist with elevated permissions",
      // Git操作は複雑な推論を要する場合があるため、HaikuやSonnet等の賢いモデルを推奨
      "model": "anthropic/claude-3-5-sonnet",   
      "permission": {
        "bash": {
          "git *": "allow",
          "*": "deny" // このエージェントはGit以外は一切実行させない
        },
        "edit": "deny", // コード編集も許可しない（コミットのみに専念）
        "webfetch": "deny"
      }
    }
  },
  "categories": {
    // 'quick' カテゴリのタスクを上記エージェントに委譲
    "quick": {
      "model": "git-specialist" // ※実装によってはエージェント名でなくモデル名を指定する場合があるため注意
    }
  }
}
```

*注意*: oh-my-opencode のバージョンによっては、`categories` 設定で直接エージェント設定（permission オブジェクトなど）を記述できず、単にモデルの指定にとどまる場合がある[3]。その場合、`git-specialist` という名前のエージェントがシステムに認識されない可能性があるため、既存のビルトインエージェント（例：`explore` や `sisyphus-junior`）の設定をオーバーライドし、それをGit専用機として運用するのが確実である。

**代替案：ビルトインエージェントの改造**

```json
{
  "agents": {
    // 既存の軽量エージェント 'explore' をGitマスター用に改造
    "explore": {
      "permission": {
        "bash": {
          "git *": "allow"
        }
      }
    }
  },
  // git-masterスキルを使用する際は常に explore エージェントに委譲するようにプロンプトで指示、
  // または task(agent='explore', skills=['git-master']) で呼び出す。
}
```

## 5. 高度な実装：フックによる動的権限判定

JSON設定による静的なパターンマッチングでは対応できない複雑な要件（例：「勤務時間中のみ許可する」「特定のブランチ名の時のみ許可する」など）がある場合、あるいはJSON設定が意図通りに機能しない場合の最終手段として、**フック（Hooks）** を利用した動的判定アプローチがある。

### 5.1 PermissionRequest フックの活用

Claude Code互換レイヤーを持つOh My OpenCodeでは、PermissionRequest イベントをフックすることで、ユーザーに代わってプログラム的に承認/拒否の判断を下すことができる[9]。

この方法は、エージェントやスキルに関わらず、実行されようとしているコマンドの内容そのものをスクリプトで解析して判断するため、最も柔軟性が高い。

### 5.2 実装手順

1. **フック設定の追加**: `oh-my-opencode.json` (または `config.json`) にフック定義を追加する。

```json
{
  "hooks": {
    "PermissionRequest": [
      "scripts/auto-approve-git.sh"
    ]
  }
}
```

2. **判定スクリプトの作成**: `scripts/auto-approve-git.sh` を作成し、実行権限を付与する。

```bash
#!/bin/bash

# OpenCode/ClaudeCodeから標準入力でリクエスト詳細が渡される
# JSON形式: { "command": "git commit -m '...'", "tool": "bash",... }

# 入力を読み込む
input=$(cat)

# jqを使ってコマンド文字列を抽出（jqのインストールが必要）
cmd=$(echo "$input" | jq -r '.command')

# ロジック：コマンドが "git " で始まる場合のみ許可
if [[ "$cmd" == git* ]]; then
  # 破壊的コマンドの除外（簡易的なチェック）
  if [[ "$cmd" == *"push --force"* ]] || [[ "$cmd" == *"push -f"* ]]; then
    echo '{"behavior": "ask"}' # 危険なコマンドはユーザーに聞く
  else
    echo '{"behavior": "allow"}' # それ以外は許可
  fi
else
  # Git以外はデフォルトの挙動（ask）に任せる（または明示的にaskを返す）
  echo '{"behavior": "ask"}'
fi
```

このスクリプトアプローチは、JSON設定の制約を超えて、「コミットメッセージが特定のフォーマットに従っている場合のみ許可」といった高度なガバナンスルールを実装することも可能にする。

## 6. スキル定義レベルでの制御（Allowed Tools）

研究資料の一部には、スキル定義自体に `allowed-tools` プロパティが存在し、スキルが使用可能なツールを制限できるという記述がある[3]。しかし、これは「許可するツールを制限する（ホワイトリスト）」ものであり、「ツールの実行権限を自動承認する」設定とは異なる場合が多い。

ただし、カスタムスキル定義（SKILL.md）において、メタデータとしてエージェントの挙動を指示することは可能である。

```yaml
---
name: git-master-custom
description: Custom git master with explicit allowed tools
allowed-tools: [bash]
metadata:
  agent: git-specialist # このスキルはこのエージェントで実行することを推奨
---
```

このように定義し、前述の「エージェント分離」設定と組み合わせることで、システム全体として「このスキルはこの権限設定のエージェントで動く」という一貫性を強制することができる。

## 7. リスク評価とセキュリティガバナンス

git 操作を「ほぼフル開放」することは、開発効率を劇的に向上させる反面、セキュリティリスクを伴う。ここでは、想定されるリスクとその軽減策を体系化する。

**表1: Git操作自動化に伴うリスクと軽減策**

| リスク分類 | 具体的なシナリオ | 推奨される軽減策 |
| :---- | :---- | :---- |
| **データ損失** | エージェントが誤って `git reset --hard` を実行し、未コミットの作業内容を消去する。 | reset および clean コマンドを deny または ask に設定する（3.3節参照）。 |
| **リモート破壊** | `git push --force` により、共有リポジトリの履歴を上書きしてしまう。 | 設定ファイルで `--force` フラグを含むコマンドを明示的に禁止する。GitHub側でブランチ保護ルール（Branch Protection Rules）を有効にし、強制プッシュをリモート側でもブロックする。 |
| **機密情報の流出** | 環境変数ファイル（.env）などを誤って `git add .` でコミットし、プッシュしてしまう。 | `.gitignore` を厳格に管理する。pre-commit フックを導入し、シークレットスキャン（TruffleHogなど）を自動実行させる。 |
| **意図しない変更** | エージェントがハルシネーションを起こし、無関係なファイルを削除・変更してコミットする。 | 「アトミックコミット」を厳守させ、PR（Pull Request）ベースのワークフローを採用する。AIのコミットは必ず人間のレビューを経てからメインブランチにマージする運用にする。 |

### 7.1 "Ultrawork" モードとの兼ね合い

Oh My OpenCodeには、ユーザーの介入なしにタスクを完了までループさせる ultrawork モードが存在する[13]。このモードは本質的に権限確認をスキップ、あるいは自動承認する挙動を含む場合があるが、これは「モード」による包括的な許可であり、粒度が粗い。

本レポートで提案した `git *` に対する設定は、通常モード（インタラクティブモード）においても機能し、かつ git 以外の操作（例：不審なネットワーク通信など）に対しては防御壁を維持できる点で、ultrawork に依存するよりもセキュリティ態勢として優れている。

## 8. 実装ロードマップとトラブルシューティング

最後に、読者が自身の環境にこの設定を適用するための具体的なステップをまとめる。

### 8.1 適用ステップ

1. **現状確認**: `bunx oh-my-opencode doctor` を実行し、現在の設定ファイルの読み込み状況とエージェント構成を確認する。
2. **設定ファイルのバックアップ**: 既存の `~/.config/opencode/oh-my-opencode.json` をバックアップする。
3. **JSONの編集**: 3.3節の「推奨構成」を参考に、permission ブロックを追加する。
4. **構文チェック**: JSONC（コメント付きJSON）が正しく記述されているか確認する。
5. **動作テスト**:
   * OpenCodeを再起動する。
   * `git status` をエージェントに指示し、確認なしで実行されるかテストする。
   * `git push --force` （ドライラン推奨）を指示し、ブロックまたは確認が求められるかテストする。

### 8.2 よくある問題と解決策

* **設定が反映されない**:
  * プロジェクト直下の `.opencode/oh-my-opencode.json` が優先されている可能性がある。両方を確認する。
  * 設定対象のエージェント名が間違っている（例：Sisyphus vs sisyphus）。大文字小文字は区別される場合があるため、doctor コマンドの出力に合わせる。
* **サブエージェントで権限エラーが出る**:
  * git-master が Sisyphus ではなく、委譲された explore や sisyphus-junior で実行されている。agents ブロックでそれらのエージェントにも同様の権限設定を追加するか、全エージェントに適用する（ワイルドカード的なエージェント指定が可能かはバージョンによるため、個別に記述するのが無難である）。

## 9. 結論

Oh My OpenCodeにおける git-master スキルの権限開放は、開発者の生産性を飛躍的に向上させる鍵である。単なる「全許可」ではなく、`oh-my-opencode.json` のパターンマッチング機能を活用し、Gitコマンドの特性（参照系、更新系、破壊系）に応じた粒度の高いアクセスコントロールを実装することで、自律性と安全性を両立させることが可能である。

特に、`git *` を許可しつつ、破壊的コマンドを明示的にブロックする「セキュア・オートメーション・プロファイル」の採用は、プロフェッショナルなAI開発環境における標準的なベストプラクティスとなるべきアプローチである。これにより、エージェントは真の意味で「Gitマスター」として振る舞い、開発者は承認ボタンを押す作業から解放され、より創造的なエンジニアリングに集中することができるようになるだろう。

#### 引用文献

[1] OpenCode: Open Source AI Coding Assistant | atal upadhyay - WordPress.com, 2月 12, 2026にアクセス、 [https://atalupadhyay.wordpress.com/2026/01/20/opencode-open-source-ai-coding-assistant/](https://atalupadhyay.wordpress.com/2026/01/20/opencode-open-source-ai-coding-assistant/)
[2] oh-my-opencode has been a gamechanger : r/ClaudeCode - Reddit, 2月 12, 2026にアクセス、 [https://www.reddit.com/r/ClaudeCode/comments/1pp2tyw/ohmyopencode_has_been_a_gamechanger/](https://www.reddit.com/r/ClaudeCode/comments/1pp2tyw/ohmyopencode_has_been_a_gamechanger/)
[3] oh-my-opencode/docs/configurations.md at dev - GitHub, 2月 12, 2026にアクセス、 [https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/configurations.md](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/configurations.md)
[4] oh-my-opencode/docs/features.md at dev - GitHub, 2月 12, 2026にアクセス、 [https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/features.md](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/features.md)
[5] Building Guardrails in OpenCode to Protect Your Secure Private Information, 2月 12, 2026にアクセス、 [https://thamizhelango.medium.com/building-guardrails-in-opencode-to-protect-your-secure-private-information-3515554563ee](https://thamizhelango.medium.com/building-guardrails-in-opencode-to-protect-your-secure-private-information-3515554563ee)
[6] glennvdv/opencode-dockerized - GitHub, 2月 12, 2026にアクセス、 [https://github.com/glennvdv/opencode-dockerized](https://github.com/glennvdv/opencode-dockerized)
[7] code-yeongyu/oh-my-opencode: the best agent harness - GitHub, 2月 12, 2026にアクセス、 [https://github.com/code-yeongyu/oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)
[8] @reinamaccredy/oh-my-opencode - NPM, 2月 12, 2026にアクセス、 [https://www.npmjs.com/package/@reinamaccredy/oh-my-opencode?activeTab=dependents](https://www.npmjs.com/package/@reinamaccredy/oh-my-opencode?activeTab=dependents)
[9] feat(hooks): Add Notification and PermissionRequest hook event support · Issue #488 · code-yeongyu/oh-my-opencode - GitHub, 2月 12, 2026にアクセス、 [https://github.com/code-yeongyu/oh-my-opencode/issues/488](https://github.com/code-yeongyu/oh-my-opencode/issues/488)
[10] oh-my-opencode/docs/category-skill-guide.md at dev - GitHub, 2月 12, 2026にアクセス、 [https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/category-skill-guide.md](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/category-skill-guide.md)
[11] [Question]: is it possible to press `a` for always like opencode? · Issue #871 - GitHub, 2月 12, 2026にアクセス、 [https://github.com/code-yeongyu/oh-my-opencode/issues/871](https://github.com/code-yeongyu/oh-my-opencode/issues/871)
[12] [Bug]: category mapping by · Issue #686 · code-yeongyu/oh-my-opencode - GitHub, 2月 12, 2026にアクセス、 [https://github.com/code-yeongyu/oh-my-opencode/issues/686](https://github.com/code-yeongyu/oh-my-opencode/issues/686)
[13] Compare with Oh My OpenCode · darrenhinde OpenAgentsControl · Discussion #116 - GitHub, 2月 12, 2026にアクセス、 [https://github.com/darrenhinde/OpenAgentsControl/discussions/116](https://github.com/darrenhinde/OpenAgentsControl/discussions/116)
