variable "name_prefix" {
  description = "Stable prefix used in AWS resource names."
  type        = string
}

variable "project_name" {
  description = "Project name used in tags and ECR repository names."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "service_name" {
  description = "Service name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the target group is created."
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS cluster id or ARN."
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "ecs_capacity_provider" {
  description = "ECS capacity provider name."
  type        = string
}

variable "alb_listener_arn" {
  description = "ALB listener ARN used by the service route."
  type        = string
}

variable "target_group_name" {
  description = "Target group name. Keep it at or below 32 characters."
  type        = string
}

variable "listener_priority" {
  description = "Unique listener rule priority inside the shared ALB listener."
  type        = number
}

variable "path_patterns" {
  description = "Path patterns routed to this service."
  type        = list(string)
}

variable "service_image" {
  description = "Full container image reference used by the ECS task."
  type        = string
}

variable "image_pull_secret_arn" {
  description = "Optional Secrets Manager ARN with private registry credentials."
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Container port exposed by the Spring Boot app."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path used by the target group health check."
  type        = string
  default     = "/management/health/liveness"
}

variable "environment_variables" {
  description = "Plain environment variables injected into the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Container secret environment variables. Map key is env var name, value is ECS valueFrom."
  type        = map(string)
  default     = {}
}

variable "secret_arns" {
  description = "Secrets Manager ARNs the task execution role can read."
  type        = list(string)
  default     = []
}

variable "sqs_queue_arns" {
  description = "SQS queue ARNs the application task role can access."
  type        = list(string)
  default     = []
}

variable "cpu" {
  description = "ECS task and container CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Hard memory limit in MiB."
  type        = number
  default     = 384
}

variable "memory_reservation" {
  description = "Soft memory reservation in MiB."
  type        = number
  default     = 256
}

variable "desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 1
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during deployments. Zero allows a single tiny EC2 host to roll with downtime."
  type        = number
  default     = 0
}

variable "deployment_maximum_percent" {
  description = "Maximum percent during deployments."
  type        = number
  default     = 100
}

variable "health_check_grace_period_seconds" {
  description = "Grace period before ALB health checks can replace a new task."
  type        = number
  default     = 120
}

variable "deregistration_delay_seconds" {
  description = "ALB deregistration delay."
  type        = number
  default     = 30
}

variable "enable_autoscaling" {
  description = "Whether to create ECS service autoscaling resources."
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum task count when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum task count when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "cpu_target_value" {
  description = "CPU target value used by autoscaling."
  type        = number
  default     = 60
}

variable "create_cloudwatch_alarms" {
  description = "Whether to create service CloudWatch alarms and SNS topic."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
