locals {
  name_prefix              = "${var.project_name}-${var.environment}"
  service_short_name       = "log"
  service_name             = "logistics-service"
  contracts_sqs_ssm_prefix = "${var.contracts_ssm_root_prefix}/${var.environment}/contracts/sqs"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Layer       = "service"
    Service     = local.service_name
  }
}

data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket
    key    = "${var.environment}/${var.aws_region}/foundation/terraform.tfstate"
    region = var.aws_region
  }
}

data "aws_ssm_parameter" "package_events_name" {
  name = "${local.contracts_sqs_ssm_prefix}/package-events/name"
}

data "aws_ssm_parameter" "package_events_url" {
  name = "${local.contracts_sqs_ssm_prefix}/package-events/url"
}

data "aws_ssm_parameter" "package_events_arn" {
  name = "${local.contracts_sqs_ssm_prefix}/package-events/arn"
}

data "aws_ssm_parameter" "logistics_events_name" {
  name = "${local.contracts_sqs_ssm_prefix}/logistics-events/name"
}

data "aws_ssm_parameter" "logistics_events_url" {
  name = "${local.contracts_sqs_ssm_prefix}/logistics-events/url"
}

data "aws_ssm_parameter" "logistics_events_arn" {
  name = "${local.contracts_sqs_ssm_prefix}/logistics-events/arn"
}

resource "aws_secretsmanager_secret" "mongodb" {
  name = "${var.project_name}/${var.environment}/${local.service_name}/mongodb"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "mongodb" {
  secret_id     = aws_secretsmanager_secret.mongodb.id
  secret_string = var.mongodb_uri
}

module "redis" {
  source = "../../../../../modules/elasticache"

  name_prefix                = "${local.name_prefix}-${local.service_short_name}"
  vpc_id                     = data.terraform_remote_state.foundation.outputs.vpc_id
  private_subnet_ids         = data.terraform_remote_state.foundation.outputs.private_subnet_ids
  allowed_security_group_ids = [data.terraform_remote_state.foundation.outputs.ecs_security_group_id]
  secret_name                = "${var.project_name}/${var.environment}/${local.service_name}/redis"
  node_type                  = var.redis_node_type
  tags                       = local.tags
}

module "service" {
  source = "../../../../../modules/ecs-service"

  name_prefix              = local.name_prefix
  project_name             = var.project_name
  environment              = var.environment
  service_name             = local.service_name
  aws_region               = var.aws_region
  vpc_id                   = data.terraform_remote_state.foundation.outputs.vpc_id
  ecs_cluster_id           = data.terraform_remote_state.foundation.outputs.ecs_cluster_id
  ecs_cluster_name         = data.terraform_remote_state.foundation.outputs.ecs_cluster_name
  ecs_capacity_provider    = data.terraform_remote_state.foundation.outputs.ecs_capacity_provider_name
  alb_listener_arn         = data.terraform_remote_state.foundation.outputs.alb_active_listener_arn
  target_group_name        = "${local.name_prefix}-${local.service_short_name}-tg"
  listener_priority        = 200
  path_patterns            = ["/api/v1/hubs*", "/api/v1/routes*"]
  service_image            = var.service_image
  image_pull_secret_arn    = var.image_pull_secret_arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  memory_reservation       = var.task_memory_reservation
  desired_count            = var.desired_count
  enable_autoscaling       = var.enable_autoscaling
  min_capacity             = var.min_capacity
  max_capacity             = var.max_capacity
  cpu_target_value         = var.cpu_target_value
  create_cloudwatch_alarms = var.create_cloudwatch_alarms

  environment_variables = {
    SPRING_PROFILES_ACTIVE           = "prod"
    SERVER_PORT                      = "8080"
    JAVA_TOOL_OPTIONS                = "-XX:InitialRAMPercentage=20 -XX:MaxRAMPercentage=70"
    AWS_REGION                       = var.aws_region
    SPRING_CLOUD_AWS_REGION_STATIC   = var.aws_region
    REDIS_HOST                       = module.redis.endpoint
    REDIS_PORT                       = tostring(module.redis.port)
    APP_VIACEP_BASE_URL              = var.viacep_base_url
    APP_MESSAGING_INBOUND_QUEUE      = data.aws_ssm_parameter.package_events_name.value
    APP_MESSAGING_OUTBOUND_QUEUE     = data.aws_ssm_parameter.logistics_events_name.value
    APP_MESSAGING_INBOUND_QUEUE_URL  = data.aws_ssm_parameter.package_events_url.value
    APP_MESSAGING_OUTBOUND_QUEUE_URL = data.aws_ssm_parameter.logistics_events_url.value
  }

  secrets = {
    MONGODB_URI = aws_secretsmanager_secret.mongodb.arn
  }

  secret_arns = [
    aws_secretsmanager_secret.mongodb.arn,
    module.redis.secret_arn,
  ]

  sqs_queue_arns = [
    data.aws_ssm_parameter.package_events_arn.value,
    data.aws_ssm_parameter.logistics_events_arn.value,
  ]

  tags = local.tags
}
