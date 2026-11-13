---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

Before fanning out, find this conversation's transcript in `<session-logs>`, the host's session-log folder for the active workspace, per [Your own session logs](../../docs/hc.md#your-own-session-logs). Do not glob across every project's logs. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
find <session-logs> -name '*.jsonl' -exec ls -t {} + 2>/dev/null | head -10
```

That covers flat (`<id>.jsonl`), subagent (`<parent>/subagents/<child>.jsonl`), and date-nested layouts. For each candidate, read its first user message. Take the file whose message records the active workspace as its working directory and contains the conversation's opening user prompt. If none matches, pass a tight digest of the session instead.

## 2. Spawn three reviewers in parallel

Spawn all three reviewers at once, per [Spawn a subagent](../../docs/hc.md#spawn-a-subagent). Reviewers use MCP to look up the tickets, chat threads, and observability traces the transcript references.

Each reviewer and the synthesizer run on a role line from the models file, or on the default below when the file or the line is missing. Turn each value into a command per [Role values](../../docs/hc.md#role-values). Pick each subagent's effort for the job, per the Subagents section of the **poteto-mode** skill.

| Lens | Role line | Default value | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `opus xhigh` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `grok --always-approve -m grok-4.7 --effort xhigh` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `opus xhigh` | `references/divergent-reviewer.md` |

Pass each template verbatim as the brief, substituting the transcript path or digest where marked. Reviewers return findings in their report.

## 3. Synthesize

Spawn one subagent on the `reflect judgment, divergent, synthesizer` line (default `opus xhigh`). It spot-verifies citations through MCP. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Never edit a skill under `plugins/cache/`. Before approval, show its destination in the host's project or user skills folder, per [Rules and skills folders](../../docs/hc.md#rules-and-skills-folders), such as `.claude/skills/<skill>/` or `~/.claude/skills/<skill>/`. After approval, copy the skill folder there and edit the copy. Never open a PR or push.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the host's skill-authoring skill, such as `skill-creator` in Claude Code, and run its draft / test / iterate loop under the **authoring-a-skill** playbook.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to the skill-authoring skill and run its description-optimization loop.
- `new skill: <kebab-name>`: hand creation to the skill-authoring skill. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
