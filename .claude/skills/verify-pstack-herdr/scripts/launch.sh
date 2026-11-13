#!/bin/sh
# Start a Claude Code lead with this checkout as its plugin, in its own hc terminal.
set -eu
repo=$(cd "$(dirname "$0")/../../../.." && pwd)
id=${1:?usage: launch.sh <run-id> <prompt>}
prompt=${2:?usage: launch.sh <run-id> <prompt>}
ev="$repo/.verify/$id"
mkdir -p "$ev"
# Default: accept edits in the repo and allow the shell commands a lead needs to drive hc. Anything else stops
# at a prompt, which shows up as `blocked`. VP_PERMISSION_MODE=bypassPermissions opts in to a fully trusted lead.
if [ "${VP_PERMISSION_MODE:-}" = bypassPermissions ]; then
  set -- --permission-mode bypassPermissions
else
  set -- --permission-mode acceptEdits --allowedTools "Bash(hc:*)" "Bash(git status:*)" "Bash(git diff:*)" \
    "Bash(cat:*)" "Bash(sed:*)" "Bash(ls:*)" "Bash(node scripts/check-native.mjs:*)" "Write($ev/**)"
fi
hc run --bg --name "vp-$id" --cwd "$repo" claude --plugin-dir "$repo" \
  --settings '{"enabledPlugins":{"pstack@cursor-plugins":false}}' \
  "$@" -- "[verify-run $id] $prompt When you are done, write your final answer to $ev/answer.md and stop." > "$ev/launch.json"
cat "$ev/launch.json"
