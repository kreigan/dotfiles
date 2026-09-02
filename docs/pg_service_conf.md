# PostgreSQL connection service file

Renders a PostgreSQL [connection service](https://www.postgresql.org/docs/current/libpq-pgservice.html)
file using the configured [services](./services.md) of type `db:postgresql`.

## Overview

| | | |
|-|-|-|
| **Output file** | `$XDG_CONFIG_HOME/postgres/pg_service.conf` | |
| **Data section** | `services`, `endpoints`, `tunnels` | |
| **Drop-in folder** | - | |
