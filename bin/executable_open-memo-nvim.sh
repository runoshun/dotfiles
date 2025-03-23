#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Memo Nvim
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

osascript -l JavaScript \
  $(dirname "$0")/activate-app.js \
  "Ghostty" \
  "Memo" \
  "open -na ghostty --args  --config-file=$HOME/.config/ghostty/config-memo -e '$HOME/.local/bin/mise x neovim -- nvim'"

