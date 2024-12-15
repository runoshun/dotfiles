#!/bin/bash
set -uo pipefail

# セッションIDを取得
get_session_id() {
  tmux display-message -p '#{session_id}'
}

# 環境変数名 (セッションごとに個別の変数を持つ)
get_terminal_var_name() {
  local session_id="$(get_session_id)"
  echo "@terminal_pane_id_${session_id}"
}

# 保存されているターミナルペインのIDを取得
get_stored_pane_id() {
  local var_name="$(get_terminal_var_name)"
  tmux show-options -gv "${var_name}" 2>/dev/null
}

# ペインIDが有効かチェック
is_valid_pane() {
  local pane_id="$1"
  tmux has-session -t "${pane_id}" 2>/dev/null
}

# 現在のペインがターミナルかどうか確認
is_current_term() {
  local stored_id="$(get_stored_pane_id)"
  local current_id="$(tmux display-message -p '#{pane_id}')"
  [ "${stored_id}" = "${current_id}" ]
}

# メイン処理
stored_pane_id="$(get_stored_pane_id)"

if [ -z "${stored_pane_id}" ] || ! is_valid_pane "${stored_pane_id}"; then
  # ターミナルペインが存在しない場合、新規作成
  tmux split-window -c "#{pane_current_path}" -l 10
  new_pane_id="$(tmux display-message -p '#{pane_id}')"
  tmux set -g "$(get_terminal_var_name)" "${new_pane_id}"
else
  if is_current_term; then
    # 現在のペインがターミナルの場合、前のペインに移動
    tmux resize-pane -y 1
    tmux select-pane -t:.-
  else
    # ターミナルペインに移動
    tmux select-pane -t "${stored_pane_id}"
    tmux resize-pane -y 10
  fi
fi
