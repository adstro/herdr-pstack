#!/bin/sh
# Replace this checkout's tree with pstack from a cursor/plugins checkout at <ref>.
# Run it on the `upstream` branch only, then merge `upstream` into `main`.
set -eu
plugins=${1:?usage: import-upstream.sh <cursor-plugins-checkout> [ref]}
ref=${2:-origin/main}
here=$(cd "$(dirname "$0")/.." && pwd)
[ "$(git -C "$here" branch --show-current)" = upstream ] || { echo "switch to the upstream branch first" >&2; exit 1; }
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
git -C "$plugins" archive "$ref" pstack/skills pstack/agents pstack/docs/guide pstack/README.md pstack/LICENSE pstack/plugin.json \
  cursor-team-kit/skills/deslop cursor-team-kit/skills/control-cli cursor-team-kit/skills/control-ui | tar -x -C "$tmp"
mv "$tmp"/cursor-team-kit/skills/* "$tmp"/pstack/skills/
# Remove only tracked files, so untracked and ignored work such as .verify/ survives the import.
git -C "$here" ls-files -z -- . ':!scripts' | (cd "$here" && xargs -0 rm -f)
cp -R "$tmp"/pstack/. "$here"/
git -C "$plugins" rev-parse "$ref" > "$here/UPSTREAM"
