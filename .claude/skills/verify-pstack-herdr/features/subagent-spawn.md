# Subagent spawn

A skill that delegates starts each subagent as an `hc` terminal under the lead, on the model its role names in the models file, and collects each child's report through `hc send`.

## Sub-features

- `spawn-run` starts a child with `hc run --bg --name <name> --cwd <dir> <command> "<brief>"`.
- `spawn-model` builds the command from the role's value in `~/.config/herdr-core/pstack-models.md`, or the skill default.
- `spawn-readonly` ends a read-only Claude child's command with `--disallowedTools Edit Write NotebookEdit --`.
- `spawn-report` receives each child's result as `<hc from="tN name">...</hc>`.
- `spawn-cleanup` kills and removes each child once its work is accepted.

## How to get to it (user POV)

- Type `/pstack:how <question>`. The simple path spawns one explainer, and the complex path spawns explorers and then an explainer.
- Any `/pstack:poteto-mode` task that delegates.

## Driving it with the vp scripts

Preconditions:

- `doctor.sh` prints no `FAIL` line.
- The models file has a `how explainer` line, or the default `opus xhigh` applies.

- **Ask a how question.** Run `scripts/launch.sh spawn-<n> "/pstack:how how does scripts/check-native.mjs pick which files to scan? Take the simple path."`, then `scripts/wait.sh <run-id>`.md` exists.
- **Check the spawn.** Run `scripts/evidence.sh spawn-<n>`. `hc-commands.txt` holds an `hc run --bg --name` line whose command is `claude --model <m> --effort <e> --disallowedTools Edit Write NotebookEdit --`, with `<m>` matching the `how explainer` role.
- **Check the report.** `screen.txt` holds a `<hc from=` line from that child.
- **Check read-only.** `git-status.txt` matches the tree before the run.
- **Clean up.** Run `scripts/cleanup.sh spawn-<n>`. It prints `cleaned` and no live children.

## Gotchas

- The lead may lower or raise effort one step from the role's value, per poteto-mode's Subagents section. Check the model, and accept an effort one step off.
- A read-only child has no Write tool, so it writes its report file with a shell heredoc. A report path outside the repo is expected.
- A read-only child that runs any shell command but `hc send` stops at a permission prompt. If `screen.txt` shows the lead steering a child past one, the brief lost its read-only tool line.
- A child that shows `idle` on turn 0 may be a stale status. Read its screen before calling it stuck.
