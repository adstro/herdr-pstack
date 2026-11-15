# Install and update

A user installs pstack from the `adstro/herdr-pstack` marketplace in Claude Code or Codex, gets new releases when they update, and never gets commits that reached only `main`.

## Sub-features

- `install-fresh` installs from GitHub with no git login, in both hosts.
- `install-update` picks up a new commit on the branch the install follows.
- `install-gate` leaves an install on `release` unchanged when only `main` moves.
- `install-clean` leaves no trace in the user's real Claude Code or Codex config.

## How to get to it (user POV)

- Follow the Install section of `README.md`.
- Update with the commands in its update line.

## Driving it with the vp scripts

Preconditions:

- The repo is public on GitHub, and you can push a throwaway branch to it.
- Set `S=$PWD/.verify/install-<n>`, and give each host its own home in it, made first with `mkdir -p $S/cc $S/cx`. Codex refuses a `CODEX_HOME` that does not exist. `claude plugin` commands run with `CLAUDE_CONFIG_DIR=$S/cc` and `codex plugin` commands with `CODEX_HOME=$S/cx`. Never use `--scope local` or `--scope project` for isolation. Those scopes change only where the setting is written, and the install still lands in the real `~/.claude/plugins/`.
- Record the real config before you start: `ls ~/.claude/plugins/cache ~/.codex/plugins/cache > $S/real-before.txt`.

- **Fresh install with no login.** Run with `GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=/usr/bin/false SSH_AUTH_SOCK=` exported. Claude Code runs `claude plugin marketplace add adstro/herdr-pstack#<branch>`, then `claude plugin install pstack@herdr-pstack`. Codex runs `codex plugin marketplace add adstro/herdr-pstack --ref <branch>`, then `codex plugin add pstack@herdr-pstack`. Claude Code's proof is `.plugins["pstack@herdr-pstack"][0]` in `$S/cc/plugins/installed_plugins.json`, whose `version` is the branch head's short sha. Codex's proof is `codex plugin list` naming `pstack`, plus `docs/hc.md` present under `$S/cx/plugins/cache/herdr-pstack/pstack/`, since the skills link to it.
- **Update picks up a release.** Push a throwaway branch `install-probe-<n>` from `release`, install from it as above, then push one commit to it. Run `claude plugin marketplace update herdr-pstack`, then `claude plugin update pstack@herdr-pstack`, and `codex plugin marketplace upgrade herdr-pstack`. Claude Code's recorded `version` becomes the new short sha. Codex's cache holds the new commit's file.
- **`main` does not reach installs.** Install from `release`, and land a commit on `main` you need anyway, such as a decisions log row, rather than a probe commit. After the same update commands, the Claude Code `version` still equals `git rev-parse --short=12 origin/release`.
- **Leave nothing behind.** Delete the probe branch with `git push origin --delete install-probe-<n>`, and run `ls ~/.claude/plugins/cache ~/.codex/plugins/cache` again. Its output matches `$S/real-before.txt`, and neither `~/.claude/plugins/installed_plugins.json` nor `~/.claude/plugins/known_marketplaces.json` gained a `herdr-pstack` entry that was not there before.

## Gotchas

- `claude -p` under a fresh `CLAUDE_CONFIG_DIR` says "Not logged in", but every `claude plugin` command works there. Prove installs from `installed_plugins.json`, not from a model session.
- A Codex model session under `$S/cx` needs `~/.codex/auth.json` copied in with `/bin/cp -f`. Delete it afterward. Treat its answer as a quote check only, never as the list of installed skills.
- Claude Code updates an install only when the plugin's version changes. `.claude-plugin/plugin.json` has no `version`, so the commit sha is the version. A probe that adds a `version` makes every later update a no-op.
- `claude plugin marketplace add` takes `owner/repo`, an https git URL, or a local path. A `file://` URL is rejected, so the update probe needs a pushed branch.
- A user with no SSH key needs `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` for installs and updates started inside a session.
