# Agent-Docker 設計

## 現在の問題点

- コンテナを抜ける際にcommitしないとデータが消失
- bundleベースのワークフローが複雑
- コンテナ内でのgit操作が不安定

## 新アーキテクチャ

### ディレクトリ構造

```
~/.local/share/agent-workspaces/<repo-name>/
└── <agent-name>/
    ├── original/              # 元リポジトリのworktree
    └── copies/                # コンテナ用コピーリポジトリ
```

### ワークフロー

1. **エージェント開始**
   - ホスト側で `feature/agent-<name>` ブランチのworktreeを作成
   - コピーリポジトリが存在しない場合のみ：worktreeからbundleを作成してコピーリポジトリを生成
   - 既存コピーリポジトリがある場合：そのまま再利用
   - コピーリポジトリを `/workspace` にマウント

2. **コンテナ終了**
   - コピーリポジトリからbundleを作成（コミット済み変更のみ）
   - worktreeでbundleをpullしてマージ（履歴保持）
   - コピーリポジトリは保持（未コミット変更保護）

3. **クリーンアップ（cleanコマンド）**
   - worktreeとコピーリポジトリを削除
   - ブランチ削除は任意

### 実装詳細

```bash
# 開始時
git worktree add original/ -b feature/agent-name
if [ ! -d "copies/" ]; then
  git -C original/ bundle create ../temp.bundle HEAD
  git clone temp.bundle copies/
fi

# 終了時（履歴保持マージ）
cd copies/
# コミット済み変更がある場合のみbundle作成・マージ
if ! git diff-index --quiet HEAD --; then
  echo "未コミット変更があります。作業を保持してコンテナを終了します。"
elif [ "$(git rev-list HEAD ^origin/HEAD --count 2>/dev/null || echo 0)" -gt 0 ]; then
  git bundle create ../output.bundle HEAD
  cd ../original/
  git pull ../output.bundle
fi
```

### 利点

- **履歴保持**: bundleを使用してcommit履歴を完全保持
- **データ永続化**: ファイルシステム直接マウントで作業が失われない
- **マージ機能**: worktreeでの正式なgitマージ処理

### 主な変更点

- コンテナ内bundleスクリプト削除
- ホスト側でのbundle作成・マージ処理
- worktreeを使った履歴保持マージ