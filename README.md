# bench

My macOS terminal + tooling setup as a reproducible, single-command bootstrap.
Managed with [chezmoi](https://chezmoi.io). Rebuilds a new Mac to a consistent
state: Ghostty, Starship, zsh (oh-my-zsh), git, Homebrew packages, and the Pi
coding agent stack (Pi + OpenSpec + extensions).

## New machine

Blank machine, one command:

```bash
git clone https://github.com/csubj/bench.git ~/code/bench
~/code/bench/bootstrap.sh
```

`bootstrap.sh` installs Xcode Command Line Tools, Homebrew, `chezmoi`, and
`1password-cli`, then runs `chezmoi init --apply`. You'll be prompted once for
your name and git email.

Alternatively, if `chezmoi` is already installed:

```bash
chezmoi init --apply csubj/bench
```

## What gets set up

| Area      | Source                                                  | Applied to                             |
| --------- | ------------------------------------------------------- | -------------------------------------- |
| Shell     | `home/dot_zshrc.tmpl`, `home/dot_zshenv.tmpl`           | `~/.zshrc`, `~/.zshenv`                |
| Aliases   | `home/dot_config/zsh/aliases.zsh`                       | `~/.config/zsh/aliases.zsh`            |
| Prompt    | `home/dot_config/starship.toml`                         | `~/.config/starship.toml`              |
| Terminal  | `home/dot_config/ghostty/config`                        | `~/.config/ghostty/config`             |
| Git       | `home/dot_gitconfig.tmpl`, `home/dot_config/git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| SSH       | `home/private_dot_ssh/config.tmpl`                      | `~/.ssh/config` (1Password SSH agent)  |
| GitHub    | `home/.chezmoidata/auth.yaml`, netrc hook               | `~/.netrc` (github.com stanza only)    |
| Packages  | `home/.chezmoidata/packages.yaml`                       | Homebrew (via `brew bundle`)           |
| oh-my-zsh | `home/.chezmoiexternal.toml`                            | `~/.oh-my-zsh` (auto-updated)          |
| Pi stack  | `home/run_onchange_after_50-pi-tools.sh.tmpl`           | Pi, OpenSpec, Pi extensions            |
| AI rules  | `home/dot_config/agent-rules/`                          | Cursor, Claude Code, Pi (see below)    |

## Extending on a work machine

This repo is a personal baseline. Employer-specific packages, internal taps, and
corp tooling stay out of git — add them to untracked local files instead:

| File                            | Use for                                            |
| ------------------------------- | -------------------------------------------------- |
| `~/.config/brew/Brewfile.local` | Internal Homebrew taps, k8s/cloud CLIs, corp casks |
| `~/.config/zsh/local.zsh`       | Work aliases, VPN helpers, per-machine env vars    |
| `~/.pi/agent/settings.json`     | Pi provider/auth for that machine                  |

`chezmoi apply` scaffolds the local files once (commented examples) and never
overwrites them. The brew-bundle hook applies `Brewfile.local` after the shared
package list.

## Pi coding agent, OpenSpec & extensions

Installed automatically by `run_onchange_after_50-pi-tools.sh.tmpl`:

- **Pi core** — `@earendil-works/pi-coding-agent`
- **OpenSpec** — `@fission-ai/openspec` (global CLI; run `openspec init` per repo)
- **Extensions** (`pi install npm:<name>`): `@hypabolic/pi-hypa`,
  `pi-web-access`, `pi-mcp-adapter`, `context-mode`, `pi-subagents`
  (+ optional `@gotgenes/pi-permission-system`)

`context-mode` also needs a global npm install and an MCP server entry in
`~/.pi/agent/mcp.json` — the script handles both. Verify in a Pi session with
`ctx stats`.

Pi provider/auth config lives in `~/.pi/agent/settings.json` and is **not** managed here — set it up per
machine with `/login` or your own provider.

Custom pi-subagents you author under `~/.pi/agent/agents/*.md` are versioned via
`home/dot_pi/agent/agents/`.

## Shared agent writing rules

Every harness gets the same writing rules, copied into its own config directory.
Nothing is symlinked, so each harness reads a plain local file.

Write the rules once, in `home/dot_config/agent-rules/*.md`. They apply to
`~/.config/agent-rules/` on the machine, and
`~/.local/bin/install-agent-rules` copies them into each harness:

| Harness     | Destination                                        | Mechanism    |
| ----------- | -------------------------------------------------- | ------------ |
| Cursor      | `~/AGENTS.md`                                      | Marker block |
| Cursor      | `~/.cursor/rules/simplified-technical-english.mdc` | Whole file   |
| Claude Code | `~/.claude/CLAUDE.md`                              | Marker block |
| Pi          | `~/.pi/agent/AGENTS.md`                            | Marker block |

A marker block is delimited by `<!-- AGENT-RULES BEGIN ... -->`. The installer
replaces only that block, so blocks that other tools own (for example nvcarps)
stay intact. A harness that is not installed is skipped.

`run_onchange_after_55-agent-rules.sh.tmpl` runs the installer on every
`chezmoi apply` that changes a rule. Run `install-agent-rules` by hand after you
edit `~/.config/agent-rules` directly.

The current rule is [ASD-STE100 Simplified Technical
English](https://en.wikipedia.org/wiki/Simplified_Technical_English): short,
active, one-meaning sentences for comments, docs, and architecture text. The
full rule tables and worked examples come from
[danyuchn/asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill),
pinned by commit in `.chezmoiexternal.toml` and installed as an on-demand skill
in `~/.agents/skills/asd-ste100` (Pi, Cursor) and `~/.claude/skills/asd-ste100`
(Claude Code). To take a newer upstream version, replace the SHA in both URLs.

## Daily use

```bash
chezmoi edit ~/.zshrc      # edit a managed file
chezmoi apply              # apply changes
chezmoi cd                 # jump to the source repo to commit/push
```

- Add a **shared personal** brew tool: edit `home/.chezmoidata/packages.yaml`, then `chezmoi apply`.
- Add a **work- or machine-only** brew tool: edit `~/.config/brew/Brewfile.local` (untracked).
- Add a **Pi extension / npm CLI**: edit the `pi:` block in `packages.yaml`, then `chezmoi apply`.
- Add an **agent writing rule**: add a file to `home/dot_config/agent-rules/`, then `chezmoi apply`.

## Secrets & machine-local config

See [docs/secrets.md](docs/secrets.md). Short version: nothing secret is
committed. Portable secrets come from 1Password; machine-specific secrets,
aliases, and packages live in untracked files (`~/.config/zsh/local.zsh`,
`~/.config/brew/Brewfile.local`).

To enable optional overlays (Grafana MCP, Pi Brave Search), see
[docs/optional-config.md](docs/optional-config.md).
