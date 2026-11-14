# Gate and upstream sync

The maintainer of the port refreshes it from cursor/plugins and relies on the gate to list any Cursor-only wording or broken link the refresh brings in.

## Sub-features

- `gate-clean` passes on `main` with `0 Cursor-only hits in 0 files`.
- `gate-detect` fails and names the file and line when Cursor plumbing or a broken link is added.
- `sync-idempotent` re-importing the recorded `UPSTREAM` commit leaves the `upstream` branch unchanged.

## How to get to it (user POV)

- Run `node scripts/check-native.mjs`, or `--list` for every hit.
- Follow the sync steps in `PORTING.md`.

## Driving it with the vp scripts

Preconditions:

- A clean tree on `main` and a cursor/plugins checkout at a known path.

- **Gate passes.** Run `node scripts/check-native.mjs > .verify/gate-<n>/gate.txt; echo $? >> .verify/gate-<n>/gate.txt`. The file ends with `0 Cursor-only hits in 0 files` and `0`.
- **Gate detects.** Run `printf 'Use the Task tool.\n' >> skills/how/SKILL.md && node scripts/check-native.mjs --list`, then `git checkout skills/how/SKILL.md`. The listing names `skills/how/SKILL.md` with `Task tool`, and the exit code is `1`.
- **Sync is idempotent.** Run it in a throwaway worktree so the import never touches this checkout or `.verify/`: `w=$(mktemp -d)/sync && git worktree add -q "$w" upstream && (cd "$w" && scripts/import-upstream.sh <plugins> $(cat UPSTREAM) >/dev/null && git status --short) > .verify/gate-<n>/sync.txt; git worktree remove --force "$w"`. `sync.txt` is empty, and `git worktree list` no longer lists the worktree.

## Gotchas

- Always restore the planted line. A leftover edit poisons every later run.
- `import-upstream.sh` refuses to run off the `upstream` branch. That is the guard, not a failure.
