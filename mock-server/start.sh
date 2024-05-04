#!/bin/bash

# Get the absolute path of the current working directory
current_dir="$(pwd)"

# Open a new Terminal window and run the first script
osascript <<EOF
tell application "Terminal"
    do script "cd \"$current_dir\"; ./_internal/start_app.sh"
end tell
EOF

# Open a new Terminal window and run the second script
osascript <<EOF
tell application "Terminal"
    do script "cd \"$current_dir\"; ./_internal/start_tests.sh"
end tell
EOF
