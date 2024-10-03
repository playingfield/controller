# postgres
The postgres role will install Postgresql software and configure a database and user.

### Role Variables

By default, the [_pg_hba.conf_](https://www.postgresql.org/docs/13/auth-pg-hba-conf.html) client authentication file is configured for open access for development purposes through the _postgres_allowed_hosts_ variable:

```
postgres_allowed_hosts:
  - { type: "host", database: "all", user: "all", address: "127.0.0.1/0", method: "trust"}
```

## Example Playbook
```
---
- hosts: postgres_servers
  collections:
    - community.postgresql
    - community.general
  roles:
    - postgres
```
