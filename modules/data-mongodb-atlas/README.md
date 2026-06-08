# data-mongodb-atlas

Provisions a service-owned MongoDB Atlas **M0 free tier** cluster: project,
cluster, database user and IP access list. Outputs a ready-to-use SRV
connection string (`connection_uri`, sensitive).

This module is consumed per service (one Atlas project per service), matching
the "data store exclusive to the service" rule in `docs/architecture.md`. Atlas
allows one M0 cluster per project, so each service uses its own project.

## Provider credentials

The `mongodbatlas` provider is configured in the **service stack** (root
module), not here. It needs an Atlas API key (`public_key` / `private_key`).

## Adopting an existing cluster (toggle on without recreating data)

Set the variables to match what you already have, then `terraform import` the
existing objects so Terraform manages them in place:

```bash
terraform import 'module.mongodb[0].mongodbatlas_project.this' <PROJECT_ID>
terraform import 'module.mongodb[0].mongodbatlas_advanced_cluster.this' <PROJECT_ID>-<CLUSTER_NAME>
terraform import 'module.mongodb[0].mongodbatlas_database_user.this' <PROJECT_ID>-<USERNAME>-admin
```

Set `db_password` to the existing user's password so the generated
`connection_uri` stays valid.

## Caveats

- `connection_uri` embeds the password in plain text inside the URI. Keep
  `db_password` URL-safe (the generated one is alphanumeric).
- `ip_access_list` defaults to `0.0.0.0/0` because free-tier ECS tasks run on
  public subnets with dynamic IPs. Tighten it if you move to static egress.
