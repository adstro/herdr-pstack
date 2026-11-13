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

You need herdr with `hc` on your `PATH`.

In Claude Code, this repository is a plugin. Inside a herdr space, start Claude Code with it:

```bash
claude --plugin-dir <path to this repo>
```

If Claude Code also has the upstream pstack plugin installed, both load under the same `pstack` name. Turn the upstream one off for these sessions:

```bash
claude --plugin-dir <path to this repo> --settings '{"enabledPlugins":{"pstack@cursor-plugins":false}}'
```

Claude Code prefixes plugin commands, so `/poteto-mode` is `/pstack:poteto-mode`.

In Codex, this repository is a skills folder. Link each skill into `~/.agents/skills/`, then start Codex inside a herdr space:

```bash
mkdir -p ~/.agents/skills
ln -sfn <path to this repo>/skills/* ~/.agents/skills/
ln -sfn <path to this repo>/docs ~/.agents/docs
ln -sfn <path to this repo>/agents ~/.agents/agents
```

The skills' relative links to `docs/` and `agents/` resolve under `~/.agents/`, so those folders need links too. Keep this checkout where it is. `git pull` in it updates both hosts.

## Get started

1. Run [`/setup-pstack`](./skills/setup-pstack/SKILL.md). It detects the agent CLIs you have, asks for a reasoning budget, and writes the models file.
2. Start a task with [`/poteto-mode`](./skills/poteto-mode/SKILL.md), a goal, and a check that can pass or fail.

Stuck, or unsure which skill fits? Ask [`/poteto-help`](./skills/poteto-help/SKILL.md).

## Keeping up with upstream

The `upstream` branch holds pstack exactly as cursor/plugins ships it, and `UPSTREAM` records the commit. `main` holds the port. [`PORTING.md`](./PORTING.md) has the sync steps and the rewrite rules, and `node scripts/check-native.mjs` lists anything a sync left in Cursor wording.

## License

MIT. See [`LICENSE`](./LICENSE). pstack is by Lauren Tan. The herdr port is by Adam Stroud.
