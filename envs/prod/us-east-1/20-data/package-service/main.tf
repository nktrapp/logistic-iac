locals {
  service_name    = "package-service"
  data_ssm_prefix = "${var.ssm_root_prefix}/${var.environment}/data/${local.service_name}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Layer       = "data"
    Service     = local.service_name
  }
}

module "mongodb" {
  source = "../../../../../modules/data-mongodb-atlas"

  atlas_org_id   = var.atlas_org_id
  project_name   = var.mongodb_project_name
  cluster_name   = var.mongodb_cluster_name
  region         = var.mongodb_atlas_region
  database_name  = var.mongodb_database_name
  db_username    = var.mongodb_db_username
  db_password    = var.mongodb_db_password
  ip_access_list = var.mongodb_ip_access_list
}

resource "aws_secretsmanager_secret" "mongodb" {
  name = "${var.project_name}/${var.environment}/${local.service_name}/mongodb"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "mongodb" {
  secret_id     = aws_secretsmanager_secret.mongodb.id
  secret_string = module.mongodb.connection_uri
}

resource "aws_ssm_parameter" "mongodb_secret_arn" {
  name        = "${local.data_ssm_prefix}/mongodb/secret-arn"
  description = "ARN of the MongoDB connection secret for ${local.service_name}"
  type        = "String"
  value       = aws_secretsmanager_secret.mongodb.arn
  overwrite   = true
  tags        = local.tags
}
