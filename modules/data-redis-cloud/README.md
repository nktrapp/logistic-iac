# data-redis-cloud

Provisions a service-owned **Redis Cloud Essentials (free 30MB)** database:
subscription + database. Outputs `host`, `port` and `password` so the service
stack can publish them to Secrets Manager / the container environment.

Only `logistics-service` uses Redis, so this module is wired into that stack
only.

## Provider credentials

The `rediscloud` provider is configured in the **service stack** (root module),
not here. It needs a Redis Cloud API key (`api_key` / `secret_key`).

## Version / schema caveat

This module follows the **Essentials** resource naming introduced in the
`RedisLabs/rediscloud` provider `>= 1.4` (`rediscloud_essentials_plan`,
`rediscloud_essentials_subscription`, `rediscloud_essentials_database`). If you
pin a different provider version, confirm the resource and attribute names
(`public_endpoint`, `plan_id`) against that version before enabling.

## Adopting an existing database (toggle on without recreating data)

Match `subscription_name`, `database_name`, `plan_name`, `cloud_provider` and
`region` to what you already have, set `database_password` to the existing
password, then `terraform import` the subscription and database so Terraform
manages them in place instead of creating duplicates.
