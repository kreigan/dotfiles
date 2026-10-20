# Python interpreter

## Overview

| | |
|-|-|
| **Output file** | `$XDG_CONFIG_HOME/mise/conf.d/00-python.toml` |
| **Sync script** | `run_onchange_sync-global-venv.sh` (`home/.chezmoiscripts/`) |
| **Data section** | `python.global_venv` (defaults in `home/.chezmoidata/python.toml`) |

Python is managed by [mise](mise.md) (interpreter installation and venv
activation) and [uv](https://docs.astral.sh/uv/) (package installation).
chezmoi renders the mise drop-in file and, optionally, installs a set of
packages into the global environment.

## Global Python virtual environment

To allow running Python scripts without creating a virtual environment for each
project, a global virtual environment is created and activated by default.

The drop-in file `00-python.toml` installs the requested Python version with
mise, activates the virtual environment at `<path>/<name>` (creating it if
missing) and points uv to the mise-managed interpreter. A project-level `.venv`
or `.python-version` takes precedence inside that project, so the global
environment only applies elsewhere.

### Configuration

Configure through chezmoi data (e.g. in `~/.config/chezmoi/chezmoi.toml` or in
`home/.chezmoidata/python.toml`) under the `python.global_venv` table:

| Variable | Description | Default |
|----------|-------------|---------|
| `python_version` | Python version passed to mise. | `latest` |
| `path` | Directory containing the virtual environment. If unset, falls back to `$XDG_DATA_HOME`, then `~/.local/share`. | `~/.local/share` |
| `name` | Directory name of the virtual environment. | `global-venv` |
| `modules` | List of packages (requirement specifiers) to keep installed in the environment. | see below |

The resulting environment lives in `<path>/<name>`, by default
`~/.local/share/global-venv`.

Defaults in `home/.chezmoidata/python.toml`:

```toml
[python.global_venv]
python_version = "latest"
path = "~/.local/share"
name = "global-venv"
modules = [
  "pandas",
  "psycopg>=3.0.0",
  "requests",
  "urllib3"
]
```

Override only what you need in your local chezmoi config. Note that chezmoi
merges maps but replaces lists, so setting `modules` replaces the whole list:

```toml
[python.global_venv]
python_version = "3.13"
modules = ["requests", "rich"]
```

## Automatic package sync

`home/.chezmoiscripts/run_onchange_sync-global-venv.sh.tmpl` installs the
packages from `modules` into the global environment on `chezmoi apply`.

The script installs exactly the packages listed in `modules` with
`uv pip sync` (via `mise exec`, so it targets the global venv), so anything else in the global venv is removed: `modules` is the
single source of truth.

Behavior:

- **`run_onchange_`** — the script runs only when its rendered content changes,
  i.e. when the `modules` list changes. Changing `python_version`, `path` or
  `name` does not re-trigger it.
- **Suppressed when `modules` is empty** — the whole body is wrapped in
  `if and $modules ...`, so an empty (or missing) list renders an empty script,
  which chezmoi does not execute. Set `modules = []` to manage the environment
  manually without the sync removing anything.
- **Order** — runs after the [mise tool installation](mise.md#automatic-tool-installation) script.
- **Linux only** — the script is rendered only when `.chezmoi.os` is `linux`.

To force a re-run, run `chezmoi state delete-bucket --bucket=scriptState`
(re-runs all `run_onchange_` scripts) or change the `modules` list.
