output "logistics_service_url" {
  description = "Logistics Service URL through the shared ALB."
  value       = "http://${data.terraform_remote_state.foundation.outputs.alb_dns_name}/api/v1/hubs"
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.service.service_name
}

output "elasticache_endpoint" {
  description = "Redis endpoint."
  value       = module.redis.endpoint
}

output "mongodb_secret_arn" {
  description = "MongoDB secret ARN."
  value       = aws_secretsmanager_secret.mongodb.arn
}

output "redis_secret_arn" {
  description = "Redis secret ARN."
  value       = module.redis.secret_arn
}

output "package_events_queue_url" {
  description = "Package events queue URL."
  value       = nonsensitive(data.aws_ssm_parameter.package_events_url.value)
}

output "logistics_events_queue_url" {
  description = "Logistics events queue URL."
  value       = nonsensitive(data.aws_ssm_parameter.logistics_events_url.value)
}
