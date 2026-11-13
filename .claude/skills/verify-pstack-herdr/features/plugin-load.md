# Plugin load

When a user starts Claude Code with `--plugin-dir` pointing at this repo, the port's skills register under `/pstack:` and run from this checkout, not from an installed upstream pstack.

## Sub-features

- `load-skills` registers every skill in `skills/` as `/pstack:<name>`.
- `load-source` runs the skill body from this repo's `skills/`, not from `cursor/plugins`.
- `load-agents` makes `agents/poteto-agent.md` readable at a stable path.

## How to get to it (user POV)

- Run `claude --plugin-dir <repo>` in a herdr space and type `/pstack:poteto-help`.
- Type `/` in that session and pick a `pstack:` entry.

## Driving it with the vp scripts

Preconditions:

- `doctor.sh` prints no `FAIL` line.

- **Ask for help.** Run `scripts/launch.sh load-<n> "/pstack:poteto-help which skill explains how a piece of code works?"`, then `hc wait vp-load-<n>` until it stops working. `answer.md` names `/how`.
- **Check the source.** Run `scripts/evidence.sh load-<n>`. `skills-loaded.txt` lists `<repo>/skills/poteto-help` and nothing under `cursor/plugins`.
- **Clean up.** Run `scripts/cleanup.sh load-<n>`. It prints `cleaned`.

## Gotchas

- Without the `--settings` override in `launch.sh`, the installed upstream plugin can load under the same `pstack` name and answer instead.
- A skill the lead never invokes leaves no `Base directory` line, so an empty `skills-loaded.txt` means the slash command did not run.
