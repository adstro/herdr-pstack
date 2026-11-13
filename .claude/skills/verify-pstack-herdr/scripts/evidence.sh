#!/bin/sh
# Capture proof for a run: lead screen, the hc commands it ran, live children, skill loads, repo state.
set -eu
repo=$(cd "$(dirname "$0")/../../../.." && pwd)
id=${1:?usage: evidence.sh <run-id>}
ev="$repo/.verify/$id"
mkdir -p "$ev"
hc read --lines 400 "vp-$id" > "$ev/screen.tmp" 2>/dev/null && mv "$ev/screen.tmp" "$ev/screen.txt" || rm -f "$ev/screen.tmp"
lead=$(hc get "vp-$id" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["address"])' 2>/dev/null || echo none)
hc ls | python3 -c 'import json,sys; [print(t["address"], t.get("name"), t.get("status"), " ".join(t.get("argv", [])[:9])) for t in json.load(sys.stdin)["terminals"] if t.get("parent") == sys.argv[1]]' "$lead" > "$ev/children.txt"
slug=$(printf %s "$repo" | sed 's/[^A-Za-z0-9]/-/g')
log=$(python3 - "$id" "$HOME/.claude/projects/$slug" <<'PY'
import glob, json, sys
marker = f"[verify-run {sys.argv[1]}]"
for path in glob.glob(f"{sys.argv[2]}/*.jsonl"):
    for line in open(path):
        d = json.loads(line)
        if d.get("type") != "user" or d.get("isMeta"): continue
        c = d["message"].get("content")
        text = c if isinstance(c, str) else " ".join(b.get("text", "") for b in c if isinstance(b, dict))
        if text.lstrip().startswith(marker): print(path)
        break
PY
)
echo "${log:-not found}" > "$ev/session-log.txt"
if [ -n "$log" ]; then
  python3 - "$log" > "$ev/hc-commands.txt" <<'PY'
import json, sys
for line in open(sys.argv[1]):
    d = json.loads(line)
    if d.get("type") != "assistant": continue
    for b in d["message"].get("content", []):
        if isinstance(b, dict) and b.get("type") == "tool_use":
            cmd = b["input"].get("command", "")
            for l in cmd.replace("\\\n", " ").splitlines():
                if "hc " in l: print(l.strip())
PY
  grep -o 'Base directory for this skill: [^"\\]*' "$log" | sort -u > "$ev/skills-loaded.txt" || true
fi
git -C "$repo" status --short > "$ev/git-status.txt"
ls -1 "$ev"
