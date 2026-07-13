# Enabling optional local secrets & config

Some managed files stay empty until you opt in on a given machine. That keeps
`chezmoi apply` working on every host without requiring org tokens or 1Password
items you do not have there.

| Feature | Opt-in file | What happens |
| ------- | ----------- | ------------ |
| Extra MCP servers (e.g. Grafana) | `~/.config/mcp/mcp.local.json` | Merged into `~/.config/mcp/mcp.json` |
| Pi Brave Search API key | `~/.pi/web-search.local.json` | Presence enables; key comes from 1Password |

Both files are **untracked** and never committed. After changing either, run
`chezmoi apply`.

---

## MCP servers (`mcp.local.json`)

The shared template (`home/dot_config/mcp/mcp.json.tmpl`) always renders
`~/.config/mcp/mcp.json` with an empty `mcpServers` object, then merges any
servers from the local overlay.

`chezmoi apply` scaffolds an empty overlay once:

```json
{
  "mcpServers": {}
}
```

### Enable Grafana (or any machine-only server)

Edit `~/.config/mcp/mcp.local.json` (mode `0600`):

```json
{
  "mcpServers": {
    "grafana": {
      "command": "uvx",
      "args": ["mcp-grafana"],
      "env": {
        "GRAFANA_URL": "https://grafana.example.com/",
        "GRAFANA_SERVICE_ACCOUNT_TOKEN": "glsa_..."
      }
    }
  }
}
```

Then:

```bash
chmod 600 ~/.config/mcp/mcp.local.json
chezmoi apply
chezmoi cat ~/.config/mcp/mcp.json   # confirm merge
```

Remove or empty the `mcpServers` object to drop machine-only servers on the
next apply. Tokens belong only in the local file — never in the repo.

---

## Pi Brave Search (`web-search.local.json`)

The template (`home/dot_pi/web-search.json.tmpl`) renders `~/.pi/web-search.json`
as `{}` unless the opt-in file exists. When it does, `chezmoi apply` reads the
Brave Search API credential from 1Password:

`op://Private/Brave Search API/credential`

Requirements: `op` installed and signed in (`op signin`).

### Enable

```bash
mkdir -p ~/.pi
touch ~/.pi/web-search.local.json
chmod 600 ~/.pi/web-search.local.json
chezmoi apply
chezmoi cat ~/.pi/web-search.json   # should show braveApiKey
```

The opt-in file’s **contents are ignored**; only its presence matters. To
disable, delete the file and re-apply:

```bash
rm ~/.pi/web-search.local.json
chezmoi apply
```

---

## Related

- Tiered secrets model: [secrets.md](secrets.md)
- Scaffold script: `home/run_once_after_30-local-env.sh.tmpl`
