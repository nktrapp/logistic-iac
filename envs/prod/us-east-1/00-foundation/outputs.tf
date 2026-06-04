output "vpc_id" {
  description = "VPC id."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block."
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet ids."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet ids."
  value       = module.network.private_subnet_ids
}

output "alb_arn" {
  description = "Application Load Balancer ARN."
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  description = "ALB security group id."
  value       = module.alb.alb_security_group_id
}

output "alb_http_listener_arn" {
  description = "HTTP listener ARN."
  value       = module.alb.http_listener_arn
}

output "alb_https_listener_arn" {
  description = "HTTPS listener ARN, if certificate_arn is set."
  value       = module.alb.https_listener_arn
}

output "alb_active_listener_arn" {
  description = "Listener ARN services should attach to."
  value       = module.alb.active_listener_arn
}

output "ecs_cluster_id" {
  description = "ECS cluster id."
  value       = module.ecs.ecs_cluster_id
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = module.ecs.ecs_cluster_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.ecs_cluster_name
}

output "ecs_capacity_provider_name" {
  description = "ECS capacity provider name."
  value       = module.ecs.ecs_capacity_provider_name
}

output "ecs_security_group_id" {
  description = "ECS instance security group id."
  value       = module.ecs.ecs_security_group_id
}
