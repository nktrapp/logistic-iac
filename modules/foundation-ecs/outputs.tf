output "ecs_cluster_id" {
  description = "ECS cluster id."
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "ecs_capacity_provider_name" {
  description = "EC2 capacity provider name."
  value       = aws_ecs_capacity_provider.ecs.name
}

output "ecs_security_group_id" {
  description = "ECS instance security group id."
  value       = module.sg.security_group_id
}
