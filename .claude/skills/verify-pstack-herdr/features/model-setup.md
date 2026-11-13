# Model setup

`/pstack:setup-pstack` detects the agent CLIs the user has, asks for a reasoning budget, and writes one role value per line to `~/.config/herdr-core/pstack-models.md`.

## Sub-features

- `setup-detect` lists models from `claude`, `grok models`, `agy models`, and `codex debug models`.
- `setup-budget` sets every value's effort to the chosen budget, capped per program.
- `setup-write` overwrites the models file with a `# budget` line and one line per role.

## How to get to it (user POV)

- Type `/pstack:setup-pstack` and answer its two questions.

## Driving it with the vp scripts

Preconditions:

- `doctor.sh` prints no `FAIL` line.
- Back up the user's file first with `cp ~/.config/herdr-core/pstack-models.md .verify/<run-id>/models.before.md`.

- **Run setup.** Run `scripts/launch.sh setup-<n> "/pstack:setup-pstack"`. When the lead asks for a budget, read its screen and answer with `hc keys` on the option that matches the backup's `# budget` line. Accept the role table as shown.
- **Check the file.** Run `diff .verify/setup-<n>/models.before.md ~/.config/herdr-core/pstack-models.md`. Every role line is present, and each value is `<model> <effort>`, a full command, `auto`, or `inherit-parent`.
- **Restore.** Run `cp .verify/setup-<n>/models.before.md ~/.config/herdr-core/pstack-models.md`, then `scripts/cleanup.sh setup-<n>`.

## Gotchas

- This writes the user's real models file. Never skip the backup and restore.
- The question tool needs keypresses. Read the screen before each `hc keys` so you select the intended option.
