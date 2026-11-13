#!/bin/sh
# Read-only: is this machine and checkout worth driving?
repo=$(cd "$(dirname "$0")/../../../.." && pwd)
fail=0
check() { if eval "$2" >/dev/null 2>&1; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi; }
check "hc core answers" "hc ls"
check "claude on PATH" "command -v claude"
check "plugin manifest valid" "claude plugin validate '$repo/.claude-plugin/plugin.json'"
check "native gate passes" "node '$repo/scripts/check-native.mjs'"
check "no other verify run is live" "! hc ls | grep -q '\"name\":\"vp-'"
if [ -f "$HOME/.config/herdr-core/pstack-models.md" ]; then echo "ok    models file present"; else echo "note  no models file, skills use their defaults"; fi
echo "repo  $repo @ $(git -C "$repo" rev-parse --short HEAD)$(git -C "$repo" diff --quiet || echo ' (dirty)')"
exit $fail
