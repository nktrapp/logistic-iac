locals {
  service_name    = "logistics-service"
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

module "redis" {
  source = "../../../../../modules/data-redis-cloud"

  subscription_name = var.redis_subscription_name
  database_name     = var.redis_database_name
  plan_name         = var.redis_plan_name
  cloud_provider    = var.redis_cloud_provider
  region            = var.redis_cloud_region
  database_password = var.redis_password
}

resource "aws_secretsmanager_secret" "mongodb" {
  name = "${var.project_name}/${var.environment}/${local.service_name}/mongodb"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "mongodb" {
  secret_id     = aws_secretsmanager_secret.mongodb.id
  secret_string = module.mongodb.connection_uri
}

resource "aws_secretsmanager_secret" "redis" {
  name = "${var.project_name}/${var.environment}/${local.service_name}/redis"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id     = aws_secretsmanager_secret.redis.id
  secret_string = module.redis.password
}

resource "aws_ssm_parameter" "mongodb_secret_arn" {
  name        = "${local.data_ssm_prefix}/mongodb/secret-arn"
  description = "ARN of the MongoDB connection secret for ${local.service_name}"
  type        = "String"
  value       = aws_secretsmanager_secret.mongodb.arn
  overwrite   = true
  tags        = local.tags
}

resource "aws_ssm_parameter" "redis_secret_arn" {
  name        = "${local.data_ssm_prefix}/redis/secret-arn"
  description = "ARN of the Redis password secret for ${local.service_name}"
  type        = "String"
  value       = aws_secretsmanager_secret.redis.arn
  overwrite   = true
  tags        = local.tags
}

resource "aws_ssm_parameter" "redis_host" {
  name        = "${local.data_ssm_prefix}/redis/host"
  description = "Redis host for ${local.service_name}"
  type        = "String"
  value       = module.redis.host
  overwrite   = true
  tags        = local.tags
}

resource "aws_ssm_parameter" "redis_port" {
  name        = "${local.data_ssm_prefix}/redis/port"
  description = "Redis port for ${local.service_name}"
  type        = "String"
  value       = tostring(module.redis.port)
  overwrite   = true
  tags        = local.tags
}
