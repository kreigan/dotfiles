# pgcli configuration file

## Overview

| | | |
|-|-|-|
| **Output file** | `~/.config/pgcli/config` | |
| **Data section** | `pgcli` | Only `main`, `colors` and `data_formats` keys are supported. Look [here](https://github.com/dbcli/pgcli/blob/main/pgcli/pgclirc) for possible configuration parameters. |
| **Drop-in folder** | `~/.config/pgcli/named_queries/` | Put here your [named queries](https://www.pgcli.com/named_queries.md) as raw SQL files. |

## Data structure

Structure in YAML format but could be any format supported by `chezmoi` (TOML, JSON, etc.).

```yaml
pgcli:
  main:
  colors:
  data_formats:
```
