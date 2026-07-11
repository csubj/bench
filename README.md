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
| Packages  | `home/.chezmoidata/packages.yaml`                       | Homebrew (via `brew bundle`)           |
| oh-my-zsh | `home/.chezmoiexternal.toml`                            | `~/.oh-my-zsh` (auto-updated)          |
| Pi stack  | `home/run_onchange_after_50-pi-tools.sh.tmpl`           | Pi, OpenSpec, Pi extensions            |

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

## Daily use

```bash
chezmoi edit ~/.zshrc      # edit a managed file
chezmoi apply              # apply changes
chezmoi cd                 # jump to the source repo to commit/push
```

- Add a **shared personal** brew tool: edit `home/.chezmoidata/packages.yaml`, then `chezmoi apply`.
- Add a **work- or machine-only** brew tool: edit `~/.config/brew/Brewfile.local` (untracked).
- Add a **Pi extension / npm CLI**: edit the `pi:` block in `packages.yaml`, then `chezmoi apply`.

## Secrets & machine-local config

See [docs/secrets.md](docs/secrets.md). Short version: nothing secret is
committed. Portable secrets come from 1Password; machine-specific secrets,
aliases, and packages live in untracked files (`~/.config/zsh/local.zsh`,
`~/.config/brew/Brewfile.local`).
