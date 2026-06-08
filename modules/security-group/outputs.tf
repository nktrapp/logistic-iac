output "security_group_id" {
  description = "Security group id."
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "Security group ARN."
  value       = aws_security_group.this.arn
}

output "security_group_name" {
  description = "Generated security group name."
  value       = aws_security_group.this.name
}
