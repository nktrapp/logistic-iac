output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.service.name
}

output "service_arn" {
  description = "ECS service ARN."
  value       = aws_ecs_service.service.id
}

output "task_definition_arn" {
  description = "Task definition ARN."
  value       = aws_ecs_task_definition.service.arn
}

output "target_group_arn" {
  description = "Target group ARN."
  value       = aws_lb_target_group.service.arn
}

output "log_group_name" {
  description = "CloudWatch log group name."
  value       = aws_cloudwatch_log_group.service.name
}
