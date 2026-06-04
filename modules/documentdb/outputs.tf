output "endpoint" {
  description = "DocumentDB cluster endpoint."
  value       = aws_docdb_cluster.main.endpoint
}

output "cluster_arn" {
  description = "DocumentDB cluster ARN."
  value       = aws_docdb_cluster.main.arn
}

output "security_group_id" {
  description = "DocumentDB security group id."
  value       = aws_security_group.documentdb.id
}

output "secret_arn" {
  description = "Secrets Manager secret ARN with MongoDB credentials."
  value       = aws_secretsmanager_secret.mongodb.arn
}

output "database_secret_value_from" {
  description = "ECS valueFrom string for the database-specific URI."
  value       = "${aws_secretsmanager_secret.mongodb.arn}:${var.database_secret_key}::"
}
