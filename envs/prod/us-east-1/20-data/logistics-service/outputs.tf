output "mongodb_secret_arn" {
  description = "MongoDB connection secret ARN."
  value       = aws_secretsmanager_secret.mongodb.arn
}

output "redis_secret_arn" {
  description = "Redis password secret ARN."
  value       = aws_secretsmanager_secret.redis.arn
}

output "redis_host" {
  description = "Redis host."
  value       = module.redis.host
}

output "redis_port" {
  description = "Redis port."
  value       = module.redis.port
}

output "data_ssm_prefix" {
  description = "SSM prefix where this service's data contract is published."
  value       = local.data_ssm_prefix
}
