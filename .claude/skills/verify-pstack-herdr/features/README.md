# pstack for herdr verification map

This directory is the maintained source for verifying the herdr port's user-facing behavior. Read the index before driving, then use the matching feature file as the recipe.

## Baseline preconditions

- `scripts/doctor.sh` prints no `FAIL` line.
- The run id is new, so `.verify/<run-id>/` starts empty.
- The tree under test is committed or its dirty state is recorded from `doctor.sh` output.
- Never drive a lead this run did not start.

## Driving conventions

- Start every lead with `scripts/launch.sh`, never a bare `claude`, so the plugin, settings, and answer path match.
- Treat each prompt as literal. Keep the `/pstack:` prefix.
- Take the simple path of a skill unless the feature is about fan-out.
- Capture with `scripts/evidence.sh` before `scripts/cleanup.sh`.

## Proof and skip reporting

- Record the run id, commit, and feature ID with every artifact.
- A spawn counts only when `hc-commands.txt` holds its `hc run` line and `screen.txt` holds its `<hc from=...>` report.
- Report a feature whose precondition is missing, such as an agent CLI that is not signed in, as unverified with the reason. Do not swap in another model and call it verified.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order: `Sub-features`, `How to get to it (user POV)`, `Driving it with the vp scripts`, and `Gotchas`.

## Features

- [Plugin load](./plugin-load.md) covers the port's skills registering under `/pstack:` in place of upstream's.
- [Subagent spawn](./subagent-spawn.md) covers a skill starting hc children, reading the models file, and collecting their reports.
- [Panel fan-out](./panel-fan-out.md) covers multi-model panels with Claude, Grok, Gemini, and Codex seats.
- [Model setup](./model-setup.md) covers `/pstack:setup-pstack` writing the models file.
- [Gate and upstream sync](./gate-and-sync.md) covers the maintainer scripts that keep the port native and current.
