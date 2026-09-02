# PostgreSQL connection service file

Renders a Docker Compose file to run SSH tunnels for [endpoints](./services.md) that
are not available directly from the host machine (`needTunnel: true`). The tunnels are
managed by [tunneller](https://github.com/kreigan/tunneller).

## Overview

| | | |
|-|-|-|
| **Output file** | `$XDG_CONFIG_HOME/tunneller/compose.yaml` | |
| **Data section** | `endpoints`, `tunnels`, `gateways` | |
| **Drop-in folder** | - | |
