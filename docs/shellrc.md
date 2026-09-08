# Shell configuration

## Overview

| | | |
|-|-|-|
| **Output file** | `$XDG_CONFIG_HOME/rc.d/*` | |
| **Data section** | `shell` | |
| **Drop-in folder** | `$XDG_CONFIG_HOME/rc.d`, `$XDG_CONFIG_HOME/rc.d/bash`, `$XDG_CONFIG_HOME/rc.d/zsh` | Put here your custom shell scripts to source. |

`~/.bashrc`/`~/.zshrc` sources `*.sh` files in `$XDG_CONFIG_HOME/rc.d` in alphabetical
order. This means that these files must be compatible with both `bash` and `zsh`.

The last file, `rc.d/99-source-shell-rc.sh` determines the current shell (bash or zsh)
and sources `rc.d/bash/*.bash` or `rc.d/zsh/*.zsh` accordingly. When placing your custom
shell files, try to keep this file sourced the last unless you have a specific reason to
source it earlier.

## Data structure

Structure in TOML format but could be any format supported by `chezmoi` (YAML, JSON, etc.).

```toml
[shell]
# Convenient form to define shell aliases (should be supported by both `bash` and `zsh`)
aliases = []

# Renders to `EDITOR` environment variable
editor = "vim"

# Controls which commands are ignored in the shell history (works for both `bash` and `zsh`)
history.ignore = []

# Renders to `LESS` environment variable
less_options = []

# Renders to `PAGER` environment variable
pager = "less"

[shell.bash.history]
# Renders to `HISTTIMEFORMAT` environment variable
time_format = "%F %T"

[shell.zsh.history]
# Path to a file used by zsh to rehash autocompletions after a new package is installed
pacman_cache = "/var/cache/zsh/pacman"
```