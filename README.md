# pstack for herdr

This is a port of [pstack](https://github.com/cursor/plugins/tree/main/pstack), Lauren Tan's set of agent skills for rigorous engineering, to the herdr app and `hc`. It keeps every pstack skill and playbook and replaces only the plumbing. Upstream runs on Cursor's subagents, models, and automations. This port runs every subagent as an `hc` terminal you can watch, steer, and attach to, each on the model its role names.

For what pstack is, its philosophy, and the full skill catalog, read the [upstream pstack README](https://github.com/cursor/plugins/blob/main/pstack/README.md). For a walkthrough of a first real task, read the [guide](./docs/guide/README.md). It is the upstream guide with the setup and plumbing rewritten for herdr.

## What changes from upstream

- Subagents start with `hc run` in their own terminals and report back with `hc send`. [`docs/hc.md`](./docs/hc.md) is the one reference every skill follows.
- Model choices live in `~/.config/herdr-core/pstack-models.md`. A role can run Claude Code, Grok, Gemini through `agy`, Codex, or any other agent CLI.
- Parallel writers get their own git worktree or an `hc` machine, in place of Cursor cloud agents.
- `make-bot-ui` wakes a named bot terminal with `hc send`, in place of a webhook routine.
- `recall`, `reflect`, and the worktree audit read Claude Code and Codex session logs.
- The `deslop`, `control-cli`, and `control-ui` skills come bundled. Upstream ships them in a separate team kit.
- Upstream's benny automation pack for Slack issue reports is left out. herdr has no event triggers.

## Install

You need herdr with `hc` on your `PATH`. Install pstack once in each host you use. After that, every session of that host has it, including the ones herdr's agent menu starts.

In Claude Code:

```bash
claude plugin marketplace add adstro/herdr-pstack#release
claude plugin install pstack@herdr-pstack
```

If the upstream pstack plugin is also installed, both load under the same `pstack` name. Turn the upstream one off with `claude plugin disable pstack@cursor-plugins`. Claude Code prefixes plugin commands, so `/poteto-mode` is `/pstack:poteto-mode`.

In Codex:

```bash
codex plugin marketplace add adstro/herdr-pstack --ref release
codex plugin add pstack@herdr-pstack
```

Codex lists the skills with the same `pstack:` prefix. If you linked the skills into `~/.agents/skills/` before, remove those links.

Installs follow the `release` branch, which moves only when a new version of the port is released. To update, run `claude plugin marketplace update herdr-pstack` and then `claude plugin update pstack@herdr-pstack`, or `codex plugin marketplace upgrade herdr-pstack`. To work on pstack itself, start Claude Code with `claude --plugin-dir <path to this repo>`, which takes the place of the installed copy for that session.

## Get started

1. Run [`/setup-pstack`](./skills/setup-pstack/SKILL.md). It detects the agent CLIs you have, asks for a reasoning budget, and writes the models file.
2. Start a task with [`/poteto-mode`](./skills/poteto-mode/SKILL.md), a goal, and a check that can pass or fail.

Stuck, or unsure which skill fits? Ask [`/poteto-help`](./skills/poteto-help/SKILL.md).

## Keeping up with upstream

The `upstream` branch holds pstack exactly as cursor/plugins ships it, and `UPSTREAM` records the commit. `main` holds the port. [`PORTING.md`](./PORTING.md) has the sync steps and the rewrite rules, and `node scripts/check-native.mjs` lists anything a sync left in Cursor wording.

## License

MIT. See [`LICENSE`](./LICENSE). pstack is by Lauren Tan. The herdr port is by Adam Stroud.
