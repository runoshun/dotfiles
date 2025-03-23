#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch tmux client to 1
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

tmux switch-client -t 1-
bash $(dirname "$0")/open-ghostty.sh
