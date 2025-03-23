#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Main Ghostty
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

osascript -l JavaScript $(dirname "$0")/activate-app.js "Ghostty" "Main" "open -na ghostty"
