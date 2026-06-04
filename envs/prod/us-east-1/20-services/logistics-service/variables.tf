variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name used in AWS resource names."
  type        = string
  default     = "furb-logistics"
}

variable "owner" {
  description = "Owning team."
  type        = string
  default     = "logistics-team"
}

variable "terraform_state_bucket" {
  description = "S3 bucket holding logistic-iac remote states."
  type        = string
  default     = "logistic-iac-terraform-state"
}

variable "contracts_ssm_root_prefix" {
  description = "Root SSM prefix published by logistic-iac contracts."
  type        = string
  default     = "/logistic"
}

variable "service_image" {
  description = "Full Docker image reference for logistics-service."
  type        = string
}

variable "image_pull_secret_arn" {
  description = "Optional Secrets Manager ARN with private registry credentials."
  type        = string
  default     = ""
}

variable "mongodb_uri" {
  description = "MongoDB connection string (e.g. MongoDB Atlas SRV URI). Stored in Secrets Manager and injected as MONGODB_URI."
  type        = string
  sensitive   = true
}

variable "redis_node_type" {
  description = "Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "viacep_base_url" {
  description = "ViaCEP base URL."
  type        = string
  default     = "https://viacep.com.br/ws"
}

variable "task_cpu" {
  description = "ECS task CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "ECS task hard memory limit in MiB."
  type        = number
  default     = 384
}

variable "task_memory_reservation" {
  description = "ECS task soft memory reservation in MiB."
  type        = number
  default     = 256
}

variable "desired_count" {
  description = "Desired task count."
  type        = number
  default     = 1
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
  description = "Whether to create service CloudWatch alarms."
  type        = bool
  default     = false
}
