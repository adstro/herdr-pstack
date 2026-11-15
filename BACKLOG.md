# Backlog

## Report upstream

Problems in pstack's content. Per [`AGENTS.md`](./AGENTS.md), the port does not fix these. Each needs an issue on cursor/plugins.

- **interrogate can skip its fan-out.** On a natural prompt, a lead answered the question itself and spawned no adversaries. The port's panel test had to reword the prompt to force the seats.
- **interrogate findings lead with the worst case.** A finding titled "`.env` included" made the user ask twice whether secrets had leaked. None had. Each finding should say whether the harm exists today, checked by a run, or only could exist, before the worst case.
- **arena keeps relaunching on a dead account.** Phase A step 3 falls back only when a model or effort is rejected. A quota, billing, or sign-in error drops the seat, and the "Outputs" note should name the families that actually ran.
- **bug-fix step 4 checks only the repro.** A fix passed its repro and broke the healthy path. Step 4 should also rerun the healthy path the fix touches as a negative control and paste both outputs.
- **poteto-help's done check invites point fixes.** `references/prompting.md` "The done check" should also name a neighboring case that must still work.
- **create-verification-skill gaps.** Step 2 "Helpers" should require each wait or stop-condition helper to pass a selftest against a live target and an ended one. Step 2 "Cleanup" should keep evidence outside the working tree, or name every repo script that deletes, resets, or stages files and show none reaches it. Steps 1 and 2 should run under the user's real permission mode, and list what any elevation leaves unverified. Step 3 "Never weaken the journey" should also forbid rewording the user's prompt to force a behavior.
- **Restate the goal behind a named mechanism.** A figure-it-out run ruled out "a herdr plugin" and stopped, but the user wanted an easier install, which the marketplaces solved. poteto-mode's "evidence rules out the change, show it and stop" trigger and figure-it-out Phase A Frame should state the outcome behind the asked-for mechanism and check other ways to reach it before stopping.

## Report to herdr-core

- **hc wait semantics.** A brief passed as an argument is not a launch task, so startup `idle` ends `hc wait` at once. The manual never documents `ended` or `reason: exit`. The manual's `hc run --bg --rm ...; hc wait build` example races for a fast command.
- **hc skill discoverability.** A question about a herdr plugin did not trigger the `hc` skill, and the agent spent about 12 calls running `strings` on the binary. The skill description ("hc manual (herdr-core)") should name the herdr app, mods, layouts, and `programs.json`, or point to `herdr-app --skill`.

## Port

- **Stale run ids pass instantly.** A reused run id let `wait.sh` print `answered:` in 0 s from the previous run's file. `launch.sh` should refuse an existing `.verify/<run-id>/`, and `wait.sh` should accept only an `answer.md` newer than the launch.
- **The read-only allowlist can still write and exec.** `Bash(find:*)` allows `-fprint`, `-delete`, and `-exec`, and `Bash(sed -n:*)` allows the `w` command. Drop `find` and `sed` from the read-only flags in `docs/hc.md` in favor of the host's Read, Grep, and Glob tools, or deny those forms. Add a probe that launches a read-only child, tries each write form outside the repo, and fails if any file appears.
- **The evidence can't see skills entered by path.** `evidence.sh` finds loaded skills only through "Base directory for this skill:". Routed skills are entered by reading `<pstack>/skills/<name>/SKILL.md`, so it should also collect those reads and fail when one sits outside this repo.
- **Panel seats die on quota.** Grok returned 402 and agy hit its quota in every panel run, and neither shows in `grok models` or `agy models`. `doctor.sh` could send each panel program a one-token prompt and print quota or billing errors, and `panel-fan-out.md` would then record such a seat as unverified.
- **Vendor-branch sync friction.** Fixes to `import-upstream.sh` must be made on `upstream`, and `git switch upstream` aborts on a dirty `decisions.tsv`. Run the sync from `main`'s copy of the script inside a temporary worktree. Have the import print the diff of upstream's host-adapter files since `UPSTREAM`, so each sync reviews new host rules.
- **Self-hosted doc links.** A link to the repo's own GitHub README 404'd once the repo went private. `scripts/check-native.mjs` should flag links to the port's own hosted URL.
- **Stale cache path for children.** When `<pstack>` resolves to the commit-hashed installed cache, a `claude plugin update` during a long session may delete the folder live children point at. Not checked. Probe it in the install-and-update recipe, and resolve `<pstack>` to a stable path if it breaks.
- **Reconsider a release version.** `version` was dropped from `plugin.json` while installs tracked `main`. Now that `release` moves only on purpose, a version bump per release costs little and gives readable versions. Decide with the user, and update the PORTING.md rule that keeps the line deleted.
- **Gate message.** `scripts/check-native.mjs` should say on each hit to allowlist it when it is not plumbing, and never to reword pstack content.
- **Sync no-change check.** `import-upstream.sh --check <plugins>` should print upstream commits since `UPSTREAM` over the script's own pathspec, so no one types that path list by hand.
- **Unverified-edit flag.** `doctor.sh` could warn when commits touching `skills/`, `docs/hc.md`, or the plugin manifest are newer than the last `.verify/` run.
- **Read-only children stall on their own shell habits.** In one reflect run, all four read-only Claude children stopped at permission prompts for `cd`, variables, pipes, `python3`, or `jq`, and two reports needed `hc send` commands chained to `| tail` or containing `#` after a newline. The read-only brief in `docs/hc.md` should say one plain command per call with literal paths, and a parent with a large log should hand children a digest file.
