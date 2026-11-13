# Panel fan-out

Panel skills start one subagent per entry in a panel role, so a mixed list runs Claude, Grok, Gemini, and Codex side by side, and a cross-family judge picks from another family than the lead's.

## Sub-features

- `panel-count` starts one child per entry in `interrogate reviewers`, `arena runners`, or `architect runners`.
- `panel-commands` runs each non-Claude entry as written, with its approval flags, such as `grok --always-approve`, `agy --dangerously-skip-permissions ... -i`, or `codex --no-daemon`.
- `panel-judge` picks the arena judge from `arena cross-judge pool`, skipping the lead's family.
- `panel-fallback` runs a seat on its role default when its program rejects the model or effort, and says so.

## How to get to it (user POV)

- Type `/pstack:interrogate <a design to attack>`.
- Type `/pstack:arena <a design question>`.

## Driving it with the vp scripts

Preconditions:

- `doctor.sh` prints no `FAIL` line.
- Each program named in the panel role is on `PATH` and signed in. Check `grok models`, `agy models`, and `codex login status`.

- **Run a panel.** Run `scripts/launch.sh panel-<n> "/pstack:interrogate is a single docs/hc.md reference better than restating the spawn recipe in each skill? Run the full adversary fan-out, one seat per interrogate reviewers entry."`, then `scripts/wait.sh <run-id>`.md` exists.
- **Check the seats.** Run `scripts/evidence.sh panel-<n>`. `hc-commands.txt` holds one `hc run` line per `interrogate reviewers` entry, each with that entry's command.
- **Check the reports.** `screen.txt` holds one `<hc from=` line per seat, or a stated fallback for each seat that failed to launch.
- **Clean up.** Run `scripts/cleanup.sh panel-<n>`.

## Gotchas

- A lead can answer the question itself and skip the seats. Without `hc run` lines in `hc-commands.txt`, the run proves nothing about fan-out.

- Grok, Gemini, and Codex children read their own MCP config, not Claude's.
- A first launch of `agy` or `grok` can show a sign-in or trust screen, which leaves the seat `blocked` on turn 0.
- This feature spends the most tokens. Run it only when panel or role-value code changed.
