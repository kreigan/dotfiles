# Services

Allows to avoid duplication when working with multiple services that have the same
properties, but are located on different hosts. Convenient when you have similar
services across various regions that differ slightly.

## Overview

| | |
|-|-|
| **Service** | Anything that can be connected to, such as a database or a web service. |
| **Endpoint** | Where the service is physically located. Can be accessed directly or through a tunnel. |
| **Tunnel** | A virtual connection to the endpoint when it is in backnet and cannot be accessed directly. Uses a gateway to forward traffic to the endpoint. |
| **Gateway** | A host that can forward traffic to the endpoint. |

## Defaults and grouping

`services`, `endpoints`, and `tunnels` can be grouped together. The following table shows
the data structure for each of these three sections:

| path | meaning | description |
|------|---------|-------------|
| `default.all` | global defaults | Applied to all objects in all groups. |
| `default.<name>` | object defaults | Applied to all objects with that name across all groups. |
| `<group>.default` | group defaults | Applied to all objects in that group. |
| `<group>.<name>` | object definition | Own object definition. |

### Gateways defaults

`gateways` cannot be grouped and only support global defaults and own object definitions:

| path | meaning | description |
|------|---------|-------------|
| `gateways.default` | global defaults | Applied to all gateways. |
| `gateways.<name>` | object definition | Own gateway definition. |

### Example how defaults work

```toml
# Defaults for all services
[services.default.all]
global_param = "value"

# Defaults for service `db1` in all groups
[services.default.db1]
properties.dbname = "my_db"
properties.user = "db1_user"
endpointRef.name = "dbhost1"

# Defaults for services in group `region1`
[services.region1.default]
group_param = "value"

# Concrete services in group `region1`
[services.region1]
db1 = {}
db2.properties.user = "db2_user"
```

This defines two services `db1` and `db2` in the group `region1`. The service `db1` uses
the default values for all services, while the service `db2` overrides the `user`
property.

```yaml
db1:
  global_param: value   # From `services.default.all`
  group_param: value    # From `services.region1.default`
  properties:
    dbname: my_db
    user: db1_user
  endpointRef:
    name: dbhost1

db2:
  global_param: value
  group_param: value
  properties:
    dbname: my_db
    user: db2_user      # Own service value
  endpointRef:
    name: dbhost1
```

### Ungrouped objects

There is a special group called `ungrouped` which is used for objects that are not part
of any group.

## Data structure

### Gateway

| path | required | description |
|------|----------|-------------|
| `user` | + | The name of the user to SSH to the gateway. |
| `address` | + | The address of the gateway. |
| `properties.auth_method` | + | Authentication method to be used for SSH connection. Could be `agent` or `key`. |
| `properties.private_key` | | A path to the private SSH key on the local machine. **Required if `auth_method` is `key`**. |
| `properties.profiles` | | A list of strings that becomes a value of `profiles` section in a [tunneller](./tunneller.md) `compose` file. |

### Tunnel

| path | required | description |
|------|----------|-------------|
| `address` | + | The address to bind the tunnel on a local machine. |
| `port` | + | The port to bind the tunnel on a local machine. |
| `gatewayRef` | + | The name of the gateway the tunnel will use to forward traffic to. |

### Endpoint

| path | required | description |
|------|----------|-------------|
| `address` | + | The address to bind the tunnel on a local machine. |
| `port` | + | The port to bind the tunnel on a local machine. |
| `needTunnel` | | Indicates if the endpoint is not reachable directly and needs a tunnel. |
| `tunnelRef.name` | | The name of the tunnel to use. **Required if `needTunnel` is `true`**. |
| `tunnelRef.group` | | The group of the tunnel. If not provided, the endpoint group name is used. |

### Service

| path | required | description |
|------|----------|-------------|
| `type` | + | The type of the service. Used by templates to determine how to render the service. E.g. `db:postgresql` will be used to render PostgreSQL connection service file. |
| `endpointRef.name` | + | The name of the endpoint the services lives on. |
| `endpointRef.group` | | The group of the endpoint. If not provided, the service group name is used. |
| `properties` | | Properties of the service. Depend on the consumer. E.g. `dbname` or `user` for PostgreSQL database will be used when populating `.pg_service.conf` file. |

## Real world example

Given the following:

- Two production and one pre-production environments, each with its own gateway machine
- Production gateways use the same SSH user, pre-production gateway uses own user
- Each environment has two PostgreSQL database hosts accessible only from the gateway
- Each database host has 3 databases
- Databases have the same name and user across all environments
- SSH tunnels are running on the local machine on ports 5432 and are bound to the
loopback interface on different addresses (like 127.1.2.3, 127.4.5.6, etc.) to avoid
port conflicts

```
[ LOCAL MACHINE ]
 │
 ├── (127.3.100.5:5432) ──(SSH: preprod_user)──┐
 ├── (127.3.100.6:5432) ──(SSH: preprod_user)──┴──► [ PRE-PROD GATEWAY ] - 10.3.100.1
 │                                                      │
 │                                                      ├──► [ DB Host 1 ] ──► (3 DBs)
 │                                                      └──► [ DB Host 2 ] ──► (3 DBs)
 │                                           
 ├── (127.1.100.5:5432) ──(SSH: prod_user)─────┐
 ├── (127.1.100.6:5432) ──(SSH: prod_user)─────┴──► [ PROD 1 GATEWAY ] - 10.1.100.1
 │                                                      │
 │                                                      ├──► [ DB Host 1 ] ──► (3 DBs)
 │                                                      └──► [ DB Host 2 ] ──► (3 DBs)
 │                                           
 ├── (127.2.100.5:5432) ──(SSH: prod_user)─────┐
 └── (127.2.100.6:5432) ──(SSH: prod_user)─────┴──► [ PROD 2 GATEWAY ] - 10.2.100.1
                                                        │
                                                        ├──► [ DB Host 1 ] ──► (3 DBs)
                                                        └──► [ DB Host 2 ] ──► (3 DBs)


                                   ┌─────────────────────────---┐
                                   │       Target Gateway       │
                                   │  (SSH User: env-specific)  │
                                   └────────────┬────────────---┘
                                                │ (Private Net)
                        ┌───────────────────────┴───────────────────────┐
                        ▼  10.X.100.5                                   ▼ 10.X.100.6
         ┌─────────────────────────────┐                 ┌─────────────────────────────┐
         │       DB Host 1             │                 │       DB Host 2             │
         ├─────────────────────────────┤                 ├─────────────────────────────┤
         │  • db_app                   │                 │  • db_analytics             │
         │  • db_users                 │                 │  • db_audit                 │
         │  • db_orders                │                 │  • db_metrics               │
         └─────────────────────────────┘                 └─────────────────────────────┘
```

1. Let's start with defining gateways:

```toml
[gateways.default]
user = "prod_user"

[gateways.prod1]
address = "10.1.100.1"

[gateways.prod2]
address = "10.2.100.1"

[gateways.preprod]
address = "10.3.100.1"
# Pre-production gateway uses a different SSH user
user = "preprod_user"
```

2. Each environment has two database hosts, each require a tunnel that listen on port 5432:

```toml
[tunnels.default.all]
port = "5432"

[tunnels.prod1.default]
gatewayRef = "prod1"

[tunnels.prod2.default]
gatewayRef = "prod2"

[tunnels.preprod.default]
gatewayRef = "preprod"
```

3. Set individual tunnel addresses that will be used on the local machine (e.g. by psql):

```toml
[tunnels.prod1]
tun1.address = "127.1.100.5"
tun2.address = "127.1.100.6"

[tunnels.prod2]
tun1.address = "127.2.100.5"
tun2.address = "127.2.100.6"

[tunnels.preprod]
tun1.address = "127.3.100.5"
tun2.address = "127.3.100.6"
```

4. All endpoints serve on port 5432 and need a tunnel to be accessed:

```toml
[endpoints.default.all]
port = 5432
needTunnel = true
```

5. Link endpoints to their tunnels:

```toml
[endpoints.default.dbhost1]
tunnelRef.name = "tun1"

[endpoints.default.dbhost2]
tunnelRef.name = "tun2"
```

6. Define endpoint addresses (these are the addresses of the database hosts
in the private network):

```toml
[endpoints.prod1]
dbhost1.address = "10.1.100.5"
dbhost2.address = "10.1.100.6"

[endpoints.prod2]
dbhost1.address = "10.2.100.5"
dbhost2.address = "10.2.100.6"

[endpoints.preprod]
dbhost1.address = "10.3.100.5"
dbhost2.address = "10.3.100.6"
```

7. Since all databases have the same name and user across all environments,
we can define them in the `default` group:

```toml
[services.default.all]
type = "db:postgresql"

[services.default.db_app]
endpointRef.name = "dbhost1"
properties.dbname = "db_app"
properties.user = "app_user"

[services.default.db_users]
endpointRef.name = "dbhost1"
properties.dbname = "db_users"
properties.user = "users_user"

[services.default.db_orders]
endpointRef.name = "dbhost1"
properties.dbname = "db_orders"
properties.user = "orders_user"

[services.default.db_analytics]
endpointRef.name = "dbhost2"
properties.dbname = "db_analytics"
properties.user = "analytics_user"

[services.default.db_audit]
endpointRef.name = "dbhost2"
properties.dbname = "db_audit"
properties.user = "audit_user"

[services.default.db_metrics]
endpointRef.name = "dbhost2"
properties.dbname = "db_metrics"
properties.user = "metrics_user"
```

8. Finally, define which services each environment has. Since no customization is needed,
we can just reference the default services:

```toml
[services.prod1]
db_app = {}
db_users = {}
db_orders = {}
db_analytics = {}
db_audit = {}
db_metrics = {}

[services.prod2]
db_app = {}
db_users = {}
db_orders = {}
db_analytics = {}
db_audit = {}
db_metrics = {}

[services.preprod]
db_app = {}
db_users = {}
db_orders = {}
db_analytics = {}
db_audit = {}
db_metrics = {}
```

The final configuration (YAML used for better readability):

```yaml
gateways:
  default:
    user: prod_user
  prod1:
    address: 10.1.100.1
  prod2:
    address: 10.2.100.1
  preprod:
    address: 10.3.100.1
    user: preprod_user

tunnels:
  default:
    all:
      port: "5432"
  prod1:
    default:
      gatewayRef: prod1
    tun1:
      address: 127.1.100.5
    tun2:
      address: 127.1.100.6
  prod2:
    default:
      gatewayRef: prod2
    tun1:
      address: 127.2.100.5
    tun2:
      address: 127.2.100.6
  preprod:
    default:
      gatewayRef: preprod
    tun1:
      address: 127.3.100.5
    tun2:
      address: 127.3.100.6

endpoints:
  default:
    all:
      port: 5432
      needTunnel: true
    dbhost1:
      tunnelRef:
        name: tun1
    dbhost2:
      tunnelRef:
        name: tun2
  prod1:
    dbhost1:
      address: 10.1.100.5
    dbhost2:
      address: 10.1.100.6
  prod2:
    dbhost1:
      address: 10.2.100.5
    dbhost2:
      address: 10.2.100.6
  preprod:
    dbhost1:
      address: 10.3.100.5
    dbhost2:
      address: 10.3.100.6

services:
  default:
    all:
      type: "db:postgresql"
    db_app:
      endpointRef:
        name: dbhost1
      properties:
        dbname: db_app
        user: app_user
    db_users:
      endpointRef:
        name: dbhost1
      properties:
        dbname: db_users
        user: users_user
    db_orders:
      endpointRef:
        name: dbhost1
      properties:
        dbname: db_orders
        user: orders_user
    db_analytics:
      endpointRef:
        name: dbhost2
      properties:
        dbname: db_analytics
        user: analytics_user
    db_audit:
      endpointRef:
        name: dbhost2
      properties:
        dbname: db_audit
        user: audit_user
    db_metrics:
      endpointRef:
        name: dbhost2
      properties:
        dbname: db_metrics
        user: metrics_user

  prod1:
    db_app: {}
    db_users: {}
    db_orders: {}
    db_analytics: {}
    db_audit: {}
    db_metrics: {}

  prod2:
    db_app: {}
    db_users: {}
    db_orders: {}
    db_analytics: {}
    db_audit: {}
    db_metrics: {}

  preprod:
    db_app: {}
    db_users: {}
    db_orders: {}
    db_analytics: {}
    db_audit: {}
    db_metrics: {}
```