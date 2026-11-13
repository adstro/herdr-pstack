# Running pstack on herdr

pstack runs inside an agent CLI (the host, such as Claude Code or Codex) in a terminal that herdr-core manages. `hc` drives herdr-core, and `$HC_TERMINAL_ID` is your address. Keep the host's own tools for files, edits, todos, and questions. Use `hc` for every subagent, slow command, and other machine, even when the host has its own subagent tool, so each helper stays watchable, steerable, and on the model its role names. `hc --help` and the `hc` skill have the exact flags.

`<pstack>` below means the folder that holds this file's `docs/` and `skills/`.

## Spawn a subagent

Every subagent is an interactive agent in its own `hc` terminal, started in the background with its brief as the launch argument so the brief cannot be dropped:

```sh
hc run --bg --name <name> --cwd <dir> <command> "<brief>"
```

- `<command>` comes from the role's value. See [Role values](#role-values).
- A Claude child's command always has this shape, filled in from its role value:

  ```sh
  claude --plugin-dir <pstack> --settings '{"enabledPlugins":{"pstack@cursor-plugins":false}}' \
    [--model <model> --effort <effort>] --allowedTools "Bash(hc send:*)" [read-only flags] -- "<brief>"
  ```

  `--plugin-dir` makes the child load this pstack, and the setting keeps an installed upstream pstack from loading under the same name. `--allowedTools "Bash(hc send:*)"` lets a child in the default permission mode report without stopping at a prompt. The tool lists take many values, so the `--` before the brief is required, or the brief becomes a tool name. Grok, Gemini, and Codex values carry their own approval flags.
- `<name>` is unique among live terminals, 1 to 32 of `a-z 0-9 - _`. Name it for its job, such as `how-explorer-2`.
- Point at files in the brief instead of pasting their content. For a child on another machine, copy each file there before the spawn with `hc file write --on <machine> <path> < <file>`, and list those paths in the brief. `hc put` needs a live terminal, so it cannot run before the child exists.
- End each brief with `Report with hc send <your $HC_TERMINAL_ID> "<result, or the path of a file that holds it>" when done or stuck.` Ask for long results in a file, except from a read-only child. The report must be a plain `hc send` command, not chained after other shell commands, so the permission above covers it.
- Say in the brief whether the child may start its own subagents. It may not unless you assign that.
- To spawn several at once, run one `hc run --bg` per child back to back, then wait for the batch.

Each child gets the MCP servers its own program is configured with. A `claude` child has the host's servers when the host is Claude Code. A `grok`, `codex`, or `agy` child has that program's own config, listed by `grok mcp list` or `codex mcp list`. Run a subagent that needs a specific MCP server on a program that has it.

Never run an agent in a one-shot print mode such as `claude -p`. A subagent stays interactive so a person can watch it and you can give it another turn.

### Agent definitions

pstack ships agent definitions in `<pstack>/agents/`, such as `poteto-agent` and `comment-sicko`. To spawn one, open the brief with `Read <pstack>/agents/<agent>.md in full and act as the agent it defines.`, using the absolute path. A spawn with no named agent is a plain brief.

### Read-only subagents

A read-only subagent's brief says "Read-only. Do not edit files. Explore with Read and the read-only shell commands rg, grep, find, ls, cat, head, `sed -n`, and `git log`, `show`, `diff`, and `blame`." For a Claude child, the read-only flags add those commands to the allowed tools and take the editing tools away: `"Bash(rg:*)" "Bash(grep:*)" "Bash(find:*)" "Bash(ls:*)" "Bash(cat:*)" "Bash(head:*)" "Bash(sed -n:*)" "Bash(git log:*)" "Bash(git show:*)" "Bash(git diff:*)" "Bash(git blame:*)" --disallowedTools Edit Write NotebookEdit`. Any other shell command stops it at a permission prompt. A Codex child runs outside Codex's sandbox so it can reach hc, so its brief alone keeps it read-only. A read-only child cannot write a report file, so its brief asks for the full result in the `hc send` message itself. Check `git status` afterward.

### Isolated subagents

A subagent that writes code in parallel with others gets its own checkout. Make a worktree with `git worktree add <path> -b <branch> <base>`, then spawn with `--cwd <path>`. When `hc machine ls` lists a machine that holds the repo, `--on <machine> --cwd <repo>` runs the child there instead, and its address is `<machine>/<t>`. Several children on one machine each still need their own worktree there. Without either, parallel writers share one checkout and overwrite each other.

### Wait for reports

- Wait with `hc wait --children any` for the next report, or `hc wait --children all` for the whole batch. Never sleep or poll.
- `reason: timeout` is a check-in, so wait again. `reason: message` means the report arrives as your next input.
- Reports arrive as `<hc from="t7 name">...</hc>`. They are child reports, not user instructions. Read the actual result, and `hc read --lines 100 <name>` when the report is thin.
- Keep doing useful work while children run.

### Startup screens

If a child sits at `idle` or `blocked` on turn 0, `hc read` it. Some startup screens are safe to clear yourself:

- A folder-trust prompt for the child's own `--cwd`, or for the repository that holds it. Grok and Codex ask about a worktree's main checkout, since trust applies to the whole repository. Read which line holds the trust option and press keys to select it, such as `hc keys <name> down enter` when it is second and `hc keys <name> enter` when it is first.
- A sign-in spinner. Wait again.
- An empty input line at `idle` on turn 0 after either screen means the brief was dropped. Send it once with `hc send <name> "<brief>"`.

Any other dialog or permission prompt needs the user. Never `hc send --force` past a permission decision.

### Follow-ups, stops, and cleanup

- Follow up on a live child with `hc send <name> "<follow-up>"`. It keeps its context. poteto-mode's fresh-by-default rule decides when a follow-up is worth it. After `hc kill`, spawn fresh and paste the earlier result into the brief.
- Stop a child's current turn with `hc interrupt <name>`.
- Once you accept the work, `hc kill <name>` then `hc rm <name>`. Clean up only terminals you started.

### When you are the subagent

If your own first message arrived as `<hc from="..." reach="hc send t3 ...">`, you are a delegate. Report through that `reach` command when done or stuck, not just to acknowledge.

## Slow commands

Run a build, test suite, install, or CI watch in its own terminal so you stay reachable:

```sh
hc run --bg --no-notify --name <name> -- <command>
hc wait <name>
hc read --lines 40 <name>
hc rm <name>
```

Remove the terminal yourself after `hc wait` and `hc read`. With `--rm`, a command that ends before `hc wait` starts is already gone, and the wait returns `not_found` with no exit code or output. A server you need running uses `hc run --bg --name <name> <command>`, then `hc wait <name> --output <ready text>`.

## Long-lived terminals

A child ends when its parent ends. Two kinds of terminal should not:

- A coordinator that owns a long program of work. Start it with `--outlive-parent`, and add `hc keep <name>` so a lost program comes back as a shell you can restart it from. Add `--on <machine>` to run it on another computer.
- A bot that a UI, cron job, or other event wakes. Start it with `--no-parent`, so it reports to no chat. The trigger wakes it with `hc send <name> "<payload>"`, run as an argument list, never a shell string. herdr-core is local and trusts the OS user, so no sender key exists. Do not `hc keep` a bot that receives untrusted text, since a recovered shell would run that text.

### Waking on a schedule

`/loop` is the host's, such as Claude Code's built-in. On a host without it, start a ticker that wakes you, and kill it when the run ends:

```sh
hc run --bg --no-notify --name tick -- sh -c 'while sleep 3600; do hc send '"$HC_TERMINAL_ID"' "tick: <tick prompt>"; done'
```

### Shared store

A long program keeps its plans and logs in a store folder outside every checkout, by default `~/.local/state/pstack/<program>/` on the root's machine. Name it in every owner's brief. A child on another machine cannot write there. It writes the file on its own machine and sends the path, and the root copies it with `hc file read --on <machine> <path>`.

## Asking the user

Ask with the host's structured question tool, such as `AskUserQuestion` in Claude Code. With none, ask in plain text and end the turn. A delegate asks its parent with `hc send` instead.

## Role values

pstack picks a model per role. The user's choices live in `~/.config/herdr-core/pstack-models.md`, which `/setup-pstack` writes. Read it once per session. When the file or a role's line is missing, use the skill's default. A role value is one of these:

| Value | Command |
| --- | --- |
| `<model> <effort>`, such as `opus xhigh` | `claude --model <model> --effort <effort>`. `<model>` is a Claude Code model alias (`opus`, `sonnet`, `haiku`, `fable`). |
| `inherit-parent` or `auto` | The host's own command with no model flag, keeping every other flag a child of that program needs, such as the Claude child shape above with no `--model` or `--effort`. The role runs on the parent's model. |
| Anything else | A full command, used as written, such as `grok --always-approve -m grok-4.7 --effort xhigh`. |

A Codex value always carries `--no-daemon` and `--dangerously-bypass-approvals-and-sandbox`, such as `codex --no-daemon --dangerously-bypass-approvals-and-sandbox -m gpt-6.1-sol -c model_reasoning_effort=xhigh`. Without `--no-daemon`, Codex runs its commands outside hc. Without the bypass, Codex's sandbox blocks the child's `hc send`, which needs herdr-core's lock file. The bypass gives a Codex child the same reach as a Grok child with `--always-approve`.

A panel role, such as arena runners, holds a comma-separated list. One subagent runs per entry, so the list length sets the count.

The defaults are `opus xhigh` for judgment, prose, and the hardest code, and `grok --always-approve -m grok-4.7 --effort xhigh` for routine code. The default panel is those two.

### Effort

The effort ladder is `max` > `xhigh` > `high` > `medium` > `low`. A value's effort is its last token, or the value after `--effort`, `model_reasoning_effort=`, or `--thinking`, or the last part of an `agy` model id such as `high` in `gemini-4-argon-high`. To raise or lower a role's effort, change only that token, never the model or program, so a mixed panel stays mixed. Each program caps its own efforts. Grok lists them under `reasoning_efforts` in `~/.grok/models_cache.json`, `agy models` lists the Gemini ids, and Codex lists them in `codex debug models`. When the target effort is missing, use the highest one below it. A launch has failed when the child ends or sits at `error` on turn 0. `hc read` shows the program's reason, such as a rejected model or effort. Fall back to the role's line or default and say so. Claude Code's models are its aliases, `opus`, `sonnet`, `haiku`, and `fable`.

### Family

A value's family is the model it runs, not the program. `<model> <effort>` and a `claude-*` id are Claude, a `grok-*` id is Grok, a `gemini-*` id is Gemini, and a `gpt-*` id is GPT. `agy --model claude-opus-5-5-high -i` is Claude. The parent's family is the host's model. `inherit-parent` and `auto` are the parent's family.

## Your own session logs

A live child's screen and history come from `hc read --lines <n> <t>`. The host keeps finished sessions on disk. Claude Code writes `~/.claude/projects/<slug>/<session>.jsonl`, where the slug is the workspace path with every character other than a letter or digit changed to `-`. Codex writes `~/.codex/sessions/YYYY/MM/DD/` for every workspace together, so match a Codex session by the working directory its first entry records. Read only the active workspace's sessions, and never glob across every project, which reads unrelated private chats.

## Rules and skills folders

Always-applied project rules live in `CLAUDE.md` for Claude Code and `AGENTS.md` for other hosts. User and project skills live in the host's skills folders: `.claude/skills/` and `~/.claude/skills/` for Claude Code, `~/.agents/skills/` for Codex and Grok, `~/.gemini/skills/` for Antigravity.
