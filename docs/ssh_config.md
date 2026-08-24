# SSH client configuration file

## Overview

| | | |
|-|-|-|
| **Output file** | `~/.ssh/config` | |
| **Data section** | `ssh` | |
| **Drop-in folder** | `~/.ssh/config.d/` | Raw SSH configuration files. Take precendence over the data configuration. |

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

`chezmoi apply` will produce `~/.ssh/config` that looks like this:

```
Host anotherHost
  HostName = hostname.com
  LogLevel = error
  User = myuser

Host myHost
  HostName = myhost.com

###################
##  GROUP: PROD  ##
###################

Host prod_host1
  HostName = prodhost1.com

Host prod_host2
  HostName = prodhost2.com
  User = specialproduser

Host prod_*
  PreferredAuthentications = publickey
  User = produser
```
