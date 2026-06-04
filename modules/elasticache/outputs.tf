output "endpoint" {
  description = "Redis endpoint."
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "port" {
  description = "Redis port."
  value       = var.port
}

output "security_group_id" {
  description = "Redis security group id."
  value       = aws_security_group.redis.id
}

output "secret_arn" {
  description = "Secrets Manager secret ARN with Redis metadata."
  value       = aws_secretsmanager_secret.redis.arn
}
