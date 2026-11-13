#!/bin/sh
# Remove the lead this run started. Its children end with it. Evidence in .verify/<run-id>/ stays.
repo=$(cd "$(dirname "$0")/../../../.." && pwd)
id=${1:?usage: cleanup.sh <run-id>}
lead=$(hc get "vp-$id" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["address"])' 2>/dev/null)
hc kill "vp-$id" >/dev/null 2>&1; hc rm "vp-$id" >/dev/null 2>&1
if [ -n "$lead" ]; then
  left=$(hc ls | python3 -c 'import json,sys; print(" ".join(t["address"] for t in json.load(sys.stdin)["terminals"] if t.get("parent") == sys.argv[1]))' "$lead")
  [ -z "$left" ] || { echo "children still live: $left"; exit 1; }
fi
echo "cleaned vp-$id, evidence kept in $repo/.verify/$id"
