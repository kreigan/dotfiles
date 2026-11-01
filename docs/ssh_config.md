# SSH client configuration file

## Overview

| | | |
|-|-|-|
| **Output file** | `~/.ssh/config`, `~/.ssh/config.d/00-hosts`, `~/.ssh/config.d/05-groups` | |
| **Data section** | `ssh` | |
| **Drop-in folder** | `~/.ssh/config.d/` | Raw SSH configuration files. Are loaded in alphabetical order. |

## Data structure

Structure in TOML format but could be any format supported by `chezmoi` (YAML, JSON, etc.).

```toml
[ssh.hosts.myHost]
  HostName = "myhost.com"

[ssh.hosts.anotherHost]
  HostName = "hostname.com"
  User = "myuser"
  LogLevel = "error"

[ssh.groups.prod.options]
  User = "produser"
  PreferredAuthentications = "publickey"

[ssh.groups.prod.hosts.host1]
  HostName = "prodhost1.com"

[ssh.groups.prod.hosts.host2]
  HostName = "prodhost2.com"
  User = "specialproduser"
```

The above configuration describes the following:

- `myHost` is an alias for `myhost.com`
- `anotherHost` is an alias for `anotherhost.com` with user `myuser` and `LogLevel` set to `error`
- all `prod_*` hosts have user `produser` and `PreferredAuthentications` set to `publickey`
- `prod_host1` is an alias for `prodhost1.com`
- `prod_host2` is an alias for `prodhost2.com` with user `specialproduser`

`chezmoi apply` will produce two files in `~/.ssh/config.d`: `00-hosts` and `05-groups`.
Groups, hosts and configuration keys are sorted alphabetically in the rendered files.
Group default options always come last in the group.

`~/.ssh/config.d/00-hosts`:

```
Host anotherHost
  HostName = hostname.com
  LogLevel = error
  User = myuser

Host myHost
  HostName = myhost.com
```

`~/.ssh/config.d/05-groups`:

```
# -----------
# GROUP: PROD
# -----------

Host prod_host1
  HostName = prodhost1.com

Host prod_host2
  HostName = prodhost2.com
  User = specialproduser

Host prod_*
  PreferredAuthentications = publickey
  User = produser
```
