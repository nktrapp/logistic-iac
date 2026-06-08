resource "random_password" "db" {
  count   = var.db_password == "" ? 1 : 0
  length  = 24
  special = false
}

locals {
  db_password = var.db_password != "" ? var.db_password : random_password.db[0].result
}

resource "mongodbatlas_project" "this" {
  name   = var.project_name
  org_id = var.atlas_org_id
}

resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = mongodbatlas_project.this.id
  name         = var.cluster_name
  cluster_type = "REPLICASET"

  replication_specs = [
    {
      region_configs = [
        {
          provider_name         = "TENANT"
          backing_provider_name = "AWS"
          region_name           = var.region
          priority              = 7

          electable_specs = {
            instance_size = "M0"
          }
        }
      ]
    }
  ]
}

resource "mongodbatlas_database_user" "this" {
  project_id         = mongodbatlas_project.this.id
  username           = var.db_username
  password           = local.db_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.database_name
  }
}

resource "mongodbatlas_project_ip_access_list" "this" {
  for_each = toset(var.ip_access_list)

  project_id = mongodbatlas_project.this.id
  cidr_block = each.value
  comment    = "Managed by logistic-iac"
}
