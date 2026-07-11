# Secrets & machine-local configuration

Nothing secret is ever committed to this repo. There are three tiers of config.

## 1. Versioned, non-secret (in git)

Normal dotfiles: `~/.zshrc`, `~/.zshenv`, `~/.gitconfig`, Starship, Ghostty,
general aliases, the shared MCP base (`~/.config/mcp/mcp.json`), and package
lists. These are identical across all machines (modulo templated name/email).

## 2. Portable secrets — 1Password (rendered, not committed)

Cross-machine secrets are pulled from 1Password at `chezmoi apply` time via the
template `home/dot_config/zsh/private_secrets.zsh.tmpl`, which renders to
`~/.config/zsh/secrets.zsh` (mode `0600`, git-ignored by chezmoi's design — the
rendered target is never written back to the source repo).

Requirements: the 1Password CLI (`op`, installed via the `1password-cli` cask)
and a signed-in session (`op signin`).

To add a shared secret, edit the template and add a line like:

```zsh
export EXA_API_KEY={{ onepasswordRead "op://Private/Exa API/credential" | quote }}
```

The template ships empty by default so `chezmoi apply` never fails on a missing
item. Good candidates here: optional `pi-web-access` provider keys you want on
every machine.

## 3. Machine-specific — untracked local files

Anything that differs per machine (or is tied to one machine's accounts) lives
in untracked files that chezmoi scaffolds once and never overwrites:

| File                            | Holds                                                                      |
| ------------------------------- | -------------------------------------------------------------------------- |
| `~/.config/brew/Brewfile.local` | machine-only Homebrew packages (internal taps, k8s/cloud CLIs, corp casks) |
| `~/.pi/agent/settings.json`     | Pi provider/auth config                                                    |

- `~/.config/zsh/local.zsh` is sourced **last** by `~/.zshrc`, so it can override
  anything. Created (with commented examples) by
  `run_once_after_30-local-env.sh.tmpl`.
- `~/.config/brew/Brewfile.local` is applied **after** the shared Brewfile by
  `run_onchange_before_20-brew-bundle.sh.tmpl`.
- `~/.pi/agent/settings.json` is owned by Pi itself; the bootstrap never writes
  provider/auth config there.

### On a new machine

The scaffolds start empty (commented examples only). Fill in that machine's own
AWS profiles, Vault endpoints, Pi provider, and any machine-only packages.
