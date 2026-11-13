#!/bin/sh
# Block until the lead finishes (exit 0), finishes without an answer (3), or needs a person (2).
# hc reports a stale `idle` on turn 0 until the lead's first status, so a turn-0 return waits for screen output instead.
repo=$(cd "$(dirname "$0")/../../../.." && pwd)
id=${1:?usage: wait.sh <run-id>}
answer="$repo/.verify/$id/answer.md"
while :; do
  r=$(hc wait "vp-$id" --timeout 600) || { echo "lead is gone"; exit 2; }
  [ -f "$answer" ] && { echo "answered: $answer"; exit 0; }
  set -- $(printf %s "$r" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("reason"), d.get("status"), d.get("turn"), d.get("ended"))')
  [ "$4" = True ] && { echo "lead exited on turn $3 without writing $answer"; exit 2; }
  case "$2" in
    blocked|error) echo "lead is $2 on turn $3; read it with hc read --lines 60 vp-$id"; exit 2 ;;
    done) [ "$3" != 0 ] && { echo "lead finished turn $3 without writing $answer"; exit 3; } ;;
  esac
  [ "$3" = 0 ] && hc wait "vp-$id" --output "⏺" --timeout 120 >/dev/null 2>&1
done
