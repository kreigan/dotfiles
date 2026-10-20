# mise configuration

## Overview

| | |
|-|-|
| **Output file** | `$XDG_CONFIG_HOME/mise/conf.d/*` |
| **Data section** | `tools`, `installDevTools`, `python.global_venv` |
| **Drop-in folder** | `$XDG_CONFIG_HOME/mise/conf.d/` |

There are two ways to customize `mise`:

1. By putting drop-in files to `$XDG_CONFIG_HOME/mise/conf.d/`.
2. By editing the configuration file `$XDG_CONFIG_HOME/mise/config.toml`.

This repository only manages the drop-in files, so `config.toml` stays free for
local, unmanaged changes. Drop-ins are loaded in alphabetical order, hence the
numeric prefixes.

## Drop-in files

| File | Contents | Configurable via |
|------|----------|------------------|
| `00-python.toml` | Python interpreter and global virtual environment. See [python.md](python.md). | `python.global_venv.*` |
| `10-tools-base.toml` | Base tools: `age`, `jmespath`, `just`, `node`, `pipx`, `sops`, `sqlfluff`. | - |
| `20-tools-k8s.toml` | Kubernetes tools: `azure`, `azure-kubelogin`, `helm` (with `helm-diff` and `helm-ls`), `kubectl`. | `tools.kubectl` |
| `30-tools-dev.toml` | Development tools (Ansible, Go linters, `ruff`, `pyright`, `shellcheck`, etc.). Not rendered unless enabled. | `installDevTools` |

## Configuration

Configure the drop-ins with chezmoi data (e.g. in `~/.config/chezmoi/chezmoi.toml`
under `[data]`).

| Variable | Description | Default |
|----------|-------------|---------|
| `tools.kubectl` | Version of `kubectl` to install. Useful for pinning to the version of your cluster. | `latest` |
| `installDevTools` | Set to `true` to render `30-tools-dev.toml` and install development tools. | `false` |
| `python.global_venv.*` | Global Python environment settings, see [python.md](python.md). | |

Example:

```toml
installDevTools = true

[tools]
kubectl = "1.31"
```

## Automatic tool installation

`home/.chezmoiscripts/run_onchange_after_10-install-mise-tools.sh.tmpl` runs
`mise install` after `chezmoi apply` whenever a mise drop-in or the data driving
it (`tools`, `installDevTools`, `python.global_venv.python_version`) changes.

The script runs from `$HOME`, so mise installs what the global configuration
(including the drop-ins) declares and ignores project-local `mise.toml` files.
It is skipped if `mise` is not installed and on Windows. It runs before the
[global venv sync](python.md#automatic-package-sync), which needs `uv` and the
interpreter installed by mise.
