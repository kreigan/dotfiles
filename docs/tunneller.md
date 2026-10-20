# Tunneller

Renders a Docker Compose file to run SSH tunnels for [endpoints](./services.md) that
are not available directly from the host machine (`needTunnel: true`). The tunnels are
managed by [tunneller](https://github.com/kreigan/tunneller).

## Overview

| | | |
|-|-|-|
| **Output file** | `$XDG_CONFIG_HOME/tunneller/compose.yaml` | |
| **Data section** | `endpoints`, `tunnels`, `gateways` | |
| **Drop-in folder** | - | |


## Managing tunnels

[`tunctl`](https://github.com/kreigan/tunneller/blob/main/tunctl) wraps
`docker compose` so you don't have to remember its options. It is not
applied by chezmoi: you must deploy it manually.

```sh
tunctl start              # start all tunnels
tunctl stop               # stop and remove all tunnels
tunctl restart            # restart all tunnels
tunctl logs               # follow logs of all tunnels
tunctl status             # show all configured services

tunctl start -p work      # only the gateways in the `work` profile
tunctl logs my-gateway    # only the `my-gateway` gateway (service)
tunctl status -c work     # only the `work.yaml` compose file
```

`status` prints a `docker ps`-like table. Services that have no container yet are
listed as `not created`:

```text
PROJECT   SERVICE  CREATED        STATUS
work      gw1      5 minutes ago  Up 5 minutes
work      gw2      -              not created
```

### Multiple compose files

Every `*.yaml`/`*.yml` file in `$XDG_CONFIG_HOME/tunneller/` is treated as a
separate Compose project named after the file without its extension (lowercased,
unsupported characters replaced with `-`). By default, commands apply to all of
them; use `-c`/`--compose NAME` to pick specific ones.

Other options: `-p`/`--profile` (repeatable) limits to profiles, and service
names are gateway names. Without them, every profile and service is used. Set
`TUNNELLER_CONFIG_DIR` to read compose files from a different directory.
