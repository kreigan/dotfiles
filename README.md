# chezmoi

Use `chezmoi` [templates](https://www.chezmoi.io/user-guide/templating/) to manage multiple files using data.

Templated files are rendered by `chezmoi` based on configured data. See [docs](https://www.chezmoi.io/user-guide/templating/#testing-templates) for more information how `chezmoi` data works.

## Usage

```sh
chezmoi init --apply
```

## Supported files

> **NOTE**: unless stated otherwise, changes in managed files will be lost on the next `chezmoi apply`. To customize a managed file, modify the data or use drop-in files if available.

| File | Configuration method | Description | |
|------|----------------------|-------------|-|
| `$XDG_CONFIG_HOME/pgcli/config` | data, drop-in files | `pgcli`'s [configuration](https://www.pgcli.com/config) | [docs](docs/pgcli.md) |
| `$XDG_CONFIG_HOME/tunneller/compose.yaml` | data | Docker Compose file for SSH tunnels managed by [tunneller](https://github.com/kreigan/tunneller) | [docs](docs/tunneller.md) |
| `$XDG_CONFIG_HOME/postgres/pg_service.conf` | data | PostgreSQL [connection service file](https://www.postgresql.org/docs/current/libpq-pgservice.html) | [docs](docs/pg_service_conf.md) |
| `~/.ssh/config` | data, drop-in files | SSH client configuration | [docs](docs/ssh_config.md) |
