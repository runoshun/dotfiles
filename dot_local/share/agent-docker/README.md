# AI エージェント実行コンテナ作成スクリプト

AIエージェントを実行するためのコンテナ環境を簡単に作成するスクリプトです。

## 機能

- 指定した名前でGitブランチとworktreeを作成
- worktreeをマウントしたDockerコンテナを起動
- miseによる開発環境の自動セットアップ
- 作業中断・再開サポート（worktree永続化）
- 複数リポジトリでの並行利用対応

## 前提条件

- Git リポジトリ内で実行する
- Docker がインストールされている
- Node.js がインストールされている
- mise の設定ファイル（`.mise.toml` または `.tool-versions`）が推奨

## 使用方法

### エージェント起動・再開
```bash
./agent-runner.js <agent-name>
```

### エージェント一覧表示
```bash
./agent-runner.js list
```

### エージェント削除
```bash
./agent-runner.js clean <agent-name>
```

### 例

```bash
# 新しいエージェント作成
./agent-runner.js my-agent

# 既存エージェントの作業再開
./agent-runner.js my-agent

# エージェント一覧表示
./agent-runner.js list

# エージェント削除
./agent-runner.js clean my-agent
```

これにより以下が実行されます：

1. `feature/agent-my-agent` ブランチを作成（初回のみ）
2. `../agent-workspaces/<repo-name>/my-agent` にworktreeを作成
3. Dockerコンテナを起動し、worktreeを `/workspace` にマウント
4. コンテナ内で `mise install` を実行して開発環境をセットアップ

## ファイル構成

- `agent-runner.js`: メインスクリプト
- 一時Dockerファイル: `/tmp/Dockerfile-agent-*` に自動生成

## 重要な変更点

### 作業継続サポート
- **コンテナ終了後もworktreeが保持されます**
- 同じコマンドで作業を再開できます
- 削除は `clean` コマンドで明示的に実行

### 複数リポジトリ対応
- ワークスペースパスが `../agent-workspaces/<repo-name>/` になります
- 異なるリポジトリで同じエージェント名を使用可能

## 注意事項

- エージェント名は英数字、ハイフン、アンダースコアのみ使用可能
- 作業を完全に削除するには `clean` コマンドを使用してください
- ブランチは安全のため手動削除が必要です

## トラブルシューティング

### "Not in a git repository" エラー
- Gitリポジトリ内でスクリプトを実行してください

### "Docker is not available" エラー
- Dockerがインストールされ、実行されていることを確認してください

### mise 設定について
- `.mise.toml` または `.tool-versions` ファイルがある場合、自動的に環境がセットアップされます
- ない場合は警告が表示されますが、スクリプトは続行されます