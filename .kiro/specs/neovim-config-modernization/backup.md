# バックアップとリカバリ手順

## バックアップ
- 作業前に現在の設定をGitで確認する: `git status -sb`
- 既存のNeovim設定を退避する場合:
  - `tar -czf /tmp/nvim-config-backup.tar.gz vim/`

## リカバリ
- 主要設定を元に戻す:
  - `git checkout main -- vim/`
- 特定ファイルのみ戻す:
  - `git checkout main -- vim/init.vim`
  - `git checkout main -- vim/rc/`

## 備考
- 変更は専用ブランチで進める: `feature/neovim-config-modernization__phase1`
- 問題発生時は上記のリカバリ手順で即時復旧できることを確認する
