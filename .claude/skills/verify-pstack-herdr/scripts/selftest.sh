#!/bin/sh
# Check wait.sh against real leads: a live Claude lead must be waited through, and an exited lead must be reported.
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/../../../.." && pwd)
id=selftest-$$; fail=0
check() { if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1 (exit $2, want $3)"; fail=1; fi; }

VP_MODEL=haiku "$here/launch.sh" "$id-live" "Reply with the single word ok." >/dev/null
"$here/wait.sh" "$id-live"; check "live lead is waited through to its answer" $? 0
"$here/cleanup.sh" "$id-live" >/dev/null

mkdir -p "$repo/.verify/$id-gone"
hc run --bg --no-notify --name "vp-$id-gone" -- sh -c 'exit 7' >/dev/null
"$here/wait.sh" "$id-gone"; check "exited lead is reported as gone" $? 2
"$here/cleanup.sh" "$id-gone" >/dev/null
exit $fail
