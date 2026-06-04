output "package_service_url" {
  description = "Package Service URL through the shared ALB."
  value       = "http://${data.terraform_remote_state.foundation.outputs.alb_dns_name}/api/v1/packages"
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.service.service_name
}

output "documentdb_endpoint" {
  description = "DocumentDB endpoint."
  value       = module.documentdb.endpoint
}

output "mongodb_secret_arn" {
  description = "MongoDB secret ARN."
  value       = module.documentdb.secret_arn
}

output "package_events_queue_url" {
  description = "Package events queue URL."
  value       = nonsensitive(data.aws_ssm_parameter.package_events_url.value)
}

output "logistics_events_queue_url" {
  description = "Logistics events queue URL."
  value       = nonsensitive(data.aws_ssm_parameter.logistics_events_url.value)
}
