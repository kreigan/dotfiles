# chezmoi

Use `chezmoi` [templates](https://www.chezmoi.io/user-guide/templating/) to manage multiple files using data.
Templated files are rendered by `chezmoi` based on configured data.

## Usage

1. Upgrade the system and install the required packages:

```sh
sudo pacman -Syu --noconfirm chezmoi curl git mise uv zsh
```

2. Initialize `chezmoi`:

```sh
chezmoi init --apply kreigan
```

It is highly recommended to fork the dotfiles repository and use your own fork when initializing `chezmoi`.

## Supported files

> **NOTE**: unless stated otherwise, changes in managed files will be lost on the next `chezmoi apply`. To customize a managed file, modify the data or use drop-in files if available.

| File | Configuration method | Description | |
|------|----------------------|-------------|-|
| `$XDG_CONFIG_HOME/dircolors/theme` | - | [`dircolors`](https://dircolors.com) theme by [harishnkr](https://github.com/harishnkr/TermRainbow) | |
| `$XDG_CONFIG_HOME/git/config`, `$XDG_CONFIG_HOME/git/ignore` | data | Git configuration and global ignore file | |
| `$XDG_CONFIG_HOME/mise/conf.d/*` | data, drop-in files | [mise](https://mise.jdx.dev) tools and global Python virtual environment | [docs](docs/mise.md), [Python](docs/python.md) |
| `$XDG_CONFIG_HOME/pgcli/config` | data, drop-in files | `pgcli`'s [configuration](https://www.pgcli.com/config) | [docs](docs/pgcli.md) |
| `$XDG_CONFIG_HOME/postgres/pg_service.conf` | data | PostgreSQL [connection service file](https://www.postgresql.org/docs/current/libpq-pgservice.html) | [docs](docs/pg_service_conf.md) |
| `$XDG_CONFIG_HOME/rc.d/*` | data, drop-in files | Shell scripts sourced by the user's shell | [docs](docs/shellrc.md) |
| `$XDG_CONFIG_HOME/tunneller/compose.yaml` | data | Docker Compose file for SSH tunnels managed by [tunneller](https://github.com/kreigan/tunneller) | [docs](docs/tunneller.md) |
| `$XDG_CONFIG_HOME/vim/vimrc` | - | Vim configuration file | |
| `$XDG_CONFIG_HOME/starship.toml` | - | [Starship](https://starship.rs) configuration file | [docs](https://starship.rs/config/) |
| `~/.ssh/config` | data, drop-in files | SSH client configuration | [docs](docs/ssh_config.md) |
| `~/.bash_profile` | - | | |
| `~/.bashrc` | - | | [docs](docs/shellrc.md) |
| `~/.zshenv` | - | | [docs](docs/shellrc.md) |
| `~/.zshrc` | - | | [docs](docs/shellrc.md) |

Besides files, `chezmoi apply` runs the scripts from `home/.chezmoiscripts/` that install the [mise tools](docs/mise.md#automatic-tool-installation) and sync the [global Python virtual environment](docs/python.md#automatic-package-sync).
