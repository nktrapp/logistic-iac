resource "random_password" "db" {
  count   = var.database_password == "" ? 1 : 0
  length  = 24
  special = false
}

locals {
  database_password = var.database_password != "" ? var.database_password : random_password.db[0].result
  endpoint_parts    = split(":", rediscloud_essentials_database.this.public_endpoint)
}

data "rediscloud_essentials_plan" "this" {
  name           = var.plan_name
  cloud_provider = var.cloud_provider
  region         = var.region
}

resource "rediscloud_essentials_subscription" "this" {
  name    = var.subscription_name
  plan_id = data.rediscloud_essentials_plan.this.id
}

resource "rediscloud_essentials_database" "this" {
  subscription_id  = rediscloud_essentials_subscription.this.id
  name             = var.database_name
  password         = local.database_password
  data_persistence = var.data_persistence
  replication      = false
}
