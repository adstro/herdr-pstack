#!/bin/sh
# Start a Claude Code lead with this checkout as its plugin, in its own hc terminal.
set -eu
repo=$(cd "$(dirname "$0")/../../../.." && pwd)
id=${1:?usage: launch.sh <run-id> <prompt>}
prompt=${2:?usage: launch.sh <run-id> <prompt>}
ev="$repo/.verify/$id"
mkdir -p "$ev"
hc run --bg --name "vp-$id" --cwd "$repo" claude --plugin-dir "$repo" \
  --settings '{"enabledPlugins":{"pstack@cursor-plugins":false}}' \
  --permission-mode bypassPermissions \
  "[verify-run $id] $prompt When you are done, write your final answer to $ev/answer.md and stop." > "$ev/launch.json"
cat "$ev/launch.json"
