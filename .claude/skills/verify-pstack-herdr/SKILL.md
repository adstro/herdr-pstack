---
name: verify-pstack-herdr
description: Prove the pstack herdr port works by driving it the way a user does. Starts a Claude Code lead with this checkout as its plugin in an hc terminal, runs a /pstack skill, and captures the hc subagents it spawns, the skills it loaded, and its answer. Use after changing a skill, docs/hc.md, or the import and gate scripts, before claiming the change works.
---

# Verify pstack for herdr

The product is a Claude Code plugin whose skills spawn subagents as `hc` terminals. A user starts `claude --plugin-dir <repo>` in a herdr space and types `/pstack:<skill>`. Verification does the same from an `hc` terminal you own, then reads what the lead and its children did. Scripts live in `scripts/` beside this file. Paths below are relative to the repo root.

Every run has a run id, such as `how-0412`. The lead terminal is `vp-<run-id>`, and evidence goes to `.verify/<run-id>/`, which git ignores.

## Doctor

Run this first, and again whenever anything looks off:

```sh
.claude/skills/verify-pstack-herdr/scripts/doctor.sh
```

It checks that the hc core answers, `claude` is on `PATH`, the plugin manifest validates, `node scripts/check-native.mjs` passes, and no other `vp-*` run is live. It prints the commit under test and whether the tree is dirty. Any `FAIL` line means stop and fix that first.

After changing `launch.sh`, `wait.sh`, or `cleanup.sh`, run `.claude/skills/verify-pstack-herdr/scripts/selftest.sh`. It waits on a live `haiku` lead and on a lead that exits, and fails if `wait.sh` gets either wrong.

## Launch

```sh
.claude/skills/verify-pstack-herdr/scripts/launch.sh <run-id> "<prompt>"
```

The prompt is what a user would type, such as `/pstack:how how does scripts/check-native.mjs pick which files to scan? Take the simple path.` The script starts the lead with this checkout as the plugin, with the installed upstream `pstack@cursor-plugins` turned off. The lead runs with `--permission-mode bypassPermissions`, which the user chose so runs finish unattended. That lets the test lead run any command on this machine. Set `VP_PERMISSION_MODE` to another mode, such as `default`, to run it stricter, and expect it to stop at prompts. A bypassed lead never shows the prompts a user's lead would hit, so name that gap in the report. Children get the modes [`docs/hc.md`](../../../docs/hc.md#spawn-a-subagent) gives them, as a user's would. Writing children run with `bypassPermissions`. Read-only children run in `default` with their allowlist, so a read-only child stuck at a prompt is a real product bug. It appends a line telling the lead to write its final answer to `.verify/<run-id>/answer.md`.

Then wait for it to finish:

```sh
.claude/skills/verify-pstack-herdr/scripts/wait.sh <run-id>
```

It exits 0 once `answer.md` exists, 2 when the lead is `blocked`, errored, or gone, and 3 when the lead finished without an answer. Use it instead of a bare `hc wait`, which returns at once on the stale `idle` hc shows before the lead's first status. On exit 2, `hc read --lines 60 vp-<run-id>` and clear a folder-trust prompt with `hc keys vp-<run-id> enter`. Any other prompt is a finding to report.

## Drive

The feature map in [`features/README.md`](features/README.md) names each user-facing feature and its prompt. While the lead runs, watch it with `hc read --lines 60 vp-<run-id>` and list its children with `hc ls`. Never `hc send` into a child the lead started. The lead owns it.

## Evidence

```sh
.claude/skills/verify-pstack-herdr/scripts/evidence.sh <run-id>
```

It writes these files into `.verify/<run-id>/`:

- `screen.txt` holds the lead's screen and history.
- `hc-commands.txt` lists every shell line with an `hc` command the lead ran, from its Claude Code session log. This shows the exact `hc run` commands and models each child got.
- `skills-loaded.txt` lists each skill's base directory. Every entry must sit under this repo's `skills/`. An entry under `cursor/plugins` means the upstream plugin loaded instead.
- `children.txt` lists children still live at capture time.
- `session-log.txt` names the session log the commands came from.
- `git-status.txt` shows whether the run edited the repo.

Capture evidence before cleanup. Proof standards follow:

- Drive through `/pstack:<skill>` as a user would, never by reading a skill and acting it out yourself.
- A spawn proof needs the `hc run` line and the child's report arriving in `screen.txt` as `<hc from=...>`, not only a claim in `answer.md`.
- A read-only child must leave `git-status.txt` unchanged from the start of the run.
- Model proof is the `--model`, `-m`, or `--effort` flags in `hc-commands.txt`, checked against `~/.config/herdr-core/pstack-models.md`.

## Cleanup

```sh
.claude/skills/verify-pstack-herdr/scripts/cleanup.sh <run-id>
```

It kills and removes `vp-<run-id>`, and fails if any child of that lead is still live. Children end with their parent, so a clean lead exit takes them too. It never touches terminals this run did not start, and it never deletes `.verify/<run-id>/`. Run it after every failed attempt too.

## Isolation

Runs share the user's hc core, models file, and model accounts. Child names such as `how-explorer-1` are unique per core, so two runs at once can collide. The doctor refuses to start a second run while a `vp-*` terminal is live. A run spends real model tokens. Prefer the simple path of a skill unless the feature under test is the fan-out.
