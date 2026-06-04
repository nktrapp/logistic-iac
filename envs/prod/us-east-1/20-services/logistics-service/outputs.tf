output "logistics_service_url" {
  description = "Logistics Service URL through the shared ALB."
  value       = "http://${data.terraform_remote_state.foundation.outputs.alb_dns_name}/api/v1/hubs"
}

output "ecr_repository_url" {
  description = "Logistics Service ECR repository URL."
  value       = module.service.ecr_repository_url
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.service.service_name
}

output "documentdb_endpoint" {
  description = "DocumentDB endpoint."
  value       = module.documentdb.endpoint
}

output "elasticache_endpoint" {
  description = "Redis endpoint."
  value       = module.redis.endpoint
}

output "mongodb_secret_arn" {
  description = "MongoDB secret ARN."
  value       = module.documentdb.secret_arn
}

output "redis_secret_arn" {
  description = "Redis secret ARN."
  value       = module.redis.secret_arn
}

output "package_events_queue_url" {
  description = "Package events queue URL."
  value       = data.aws_ssm_parameter.package_events_url.value
}

output "logistics_events_queue_url" {
  description = "Logistics events queue URL."
  value       = data.aws_ssm_parameter.logistics_events_url.value
}
