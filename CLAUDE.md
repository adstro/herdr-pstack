# herdr-pstack

## Keep pstack's content

This repository ports pstack to herdr. Change only the plumbing: how subagents start, report, and stop, which model a role runs on, where rules, skills, and session logs live, and how scheduled or triggered work wakes up. Replace each with its `hc` or herdr equivalent per [`PORTING.md`](./PORTING.md).

Leave everything else as upstream ships it. That covers what each skill, agent, playbook, principle, and workflow does, its steps, its order, its prompts and briefs, and its wording beyond the plumbing terms. Do not fix, improve, or reword pstack's content here, even when a review or test finds a problem in it. Report the problem for upstream instead.

The port's own files are exempt: `docs/hc.md`, `README.md`, `PORTING.md`, `scripts/`, `.claude/skills/verify-pstack-herdr/`, and `decisions.tsv`.
