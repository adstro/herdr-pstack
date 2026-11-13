# Porting pstack to herdr

This repository is pstack from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack), rewritten to run on herdr. Every Cursor facility the skills relied on is replaced by `hc`, herdr-core, or the host agent CLI. [`docs/hc.md`](docs/hc.md) is the one reference the skills link to for that plumbing.

## Branches

- `upstream` holds pstack exactly as cursor/plugins ships it, plus the `deslop`, `control-cli`, and `control-ui` skills from `cursor-team-kit`, which pstack calls. `UPSTREAM` records the commit.
- `main` holds the port.

## Sync a new pstack

```sh
git switch upstream
scripts/import-upstream.sh <cursor-plugins-checkout> origin/main
git add -A && git commit -m "chore: import pstack <sha> from cursor/plugins"
git switch main && git merge upstream
node scripts/check-native.mjs
```

Resolve conflicts by keeping the herdr wording and carrying over upstream's behavior change. New upstream text arrives in Cursor wording without a conflict, so the gate lists it. Rewrite each hit with the rules below until the gate passes.

## The gate

`node scripts/check-native.mjs` fails while any Cursor-only term is left in the port's Markdown or shell scripts, or any relative link or heading anchor is broken. `--list` prints each hit. A mention that is not plumbing, such as the upstream author credit, goes in `scripts/native-allow.txt` as `<path>\t<substring>`. Allow a line only when it describes Cursor instead of instructing an agent to use it.

## Rewrite rules

Keep every behavior. Change only how it runs. Make the smallest edit that removes the Cursor plumbing, keep the surrounding wording, and link to [`docs/hc.md`](docs/hc.md) instead of restating its recipes. Write in short declarative sentences, with no long-dash character and no mid-sentence colon.

| Cursor | herdr |
| --- | --- |
| A `Task` subagent or call, `subagent_type: generalPurpose`, `run_in_background: true`, "in one message" | A subagent spawned per [Spawn a subagent](docs/hc.md#spawn-a-subagent). Several at once is "spawn all N at once". Drop the field names. |
| `subagent_type: poteto-agent` or `comment-sicko` | A subagent that acts as that agent, per [Agent definitions](docs/hc.md#agent-definitions). |
| `readonly: true`, Ask mode | A read-only subagent, per [Read-only subagents](docs/hc.md#read-only-subagents). |
| `readonly: false`, agent mode, "readonly strips MCP" | Drop it. Read-only does not change MCP access. A subagent that needs an MCP server runs on a program that has it, per [Spawn a subagent](docs/hc.md#spawn-a-subagent). |
| `environment: "cloud"`, cloud agents, `cloud_base_branch` | An isolated subagent in its own worktree or on an `hc` machine, per [Isolated subagents](docs/hc.md#isolated-subagents). |
| `resume`, steering a running Task | A follow-up with `hc send`, per [Follow-ups, stops, and cleanup](docs/hc.md#follow-ups-stops-and-cleanup). |
| Task `model`, a slug, "if the Task tool rejects a slug" chains, fast or standard speed | The role's value from the models file, turned into a command per [Role values](docs/hc.md#role-values). Effort changes per [Effort](docs/hc.md#effort). Drop the speed choice. |
| `claude-opus-5-5-<effort>` | `opus <effort>` |
| `claude-sonnet-5-5-<effort>` | `sonnet <effort>` |
| `grok-4.7-<effort>-fast`, `grok-4.7-<effort>` | `grok --always-approve -m grok-4.7 --effort <effort>` |
| The `pstack-models.mdc` rule, `~/.cursor/rules/pstack-models.mdc` | The models file, `~/.config/herdr-core/pstack-models.md`. |
| `AskQuestion` | The host's question tool, per [Asking the user](docs/hc.md#asking-the-user). |
| A slow shell command run in the foreground | Its own terminal, per [Slow commands](docs/hc.md#slow-commands). |
| `.cursor/skills/`, `~/.cursor/skills/` | The host's skills folders, per [Rules and skills folders](docs/hc.md#rules-and-skills-folders). |
| `.cursor/rules/*.mdc`, an always-applied rule | `CLAUDE.md` or `AGENTS.md`, per the same section. |
| `agent-transcripts/`, `~/.cursor/projects/` | The host's session logs or `hc read`, per [Your own session logs](docs/hc.md#your-own-session-logs). |
| `cursor-team-kit`'s `deslop`, `control-cli`, `control-ui` | The bundled **deslop**, **control-cli**, and **control-ui** skills at `skills/<name>/`. |
| Cursor's built-in `create-skill` | The host's skill-authoring skill, such as `skill-creator` in Claude Code, and the **authoring-a-skill** playbook. |
| Cursor's built-in `/loop` | The host's `/loop`. With none, a long-lived `hc` terminal the lead re-wakes with `hc send`. |
| Cursor Automations, routines, webhooks, `update_state`, `SendToUser` | A named agent terminal woken with `hc send <name> "<payload>"`. herdr-core is local and authenticated by the OS user, so no sender key exists. |
| A Cursor Project coordinator thread | A long-lived coordinator terminal started with `--outlive-parent`, kept with `hc keep`. |
| Restarting Cursor, going offline | Restarting the host or the Herdr app. Terminals survive app restarts. |
| `/plugin` install text, Cursor product mentions in docs | herdr install text from the README. Keep the upstream author credit and links to cursor/plugins. |
| Bugbot | Keep it. It is a GitHub-side reviewer, and its comments are ordinary review threads. Drop any step that configures it in a Cursor dashboard. |

Leave TypeScript `readonly` and GraphQL `endCursor` alone. They are code, not plumbing, and the gate skips `readonly __brand`.
