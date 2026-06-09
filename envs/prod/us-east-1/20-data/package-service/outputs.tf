output "mongodb_secret_arn" {
  description = "MongoDB connection secret ARN."
  value       = aws_secretsmanager_secret.mongodb.arn
}

output "data_ssm_prefix" {
  description = "SSM prefix where this service's data contract is published."
  value       = local.data_ssm_prefix
}
