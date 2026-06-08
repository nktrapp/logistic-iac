variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in AWS resource names."
  type        = string
  default     = "furb-logistics"
}

variable "owner" {
  description = "Owning team."
  type        = string
  default     = "package-team"
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
  description = "Full Docker image reference for package-service."
  type        = string
}

variable "image_pull_secret_arn" {
  description = "Optional Secrets Manager ARN with private registry credentials."
  type        = string
  default     = ""
}

variable "mongodb_uri" {
  description = "MongoDB connection string used when create_mongodb is false. Stored in Secrets Manager and injected as MONGODB_URI."
  type        = string
  default     = ""
  sensitive   = true
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

# --- MongoDB Atlas (data-mongodb-atlas module) ---

variable "create_mongodb" {
  description = "Manage this service's MongoDB Atlas M0 cluster via Terraform. When false, mongodb_uri is used as-is."
  type        = bool
  default     = false
}

variable "atlas_public_key" {
  description = "MongoDB Atlas API public key. Required when create_mongodb is true."
  type        = string
  default     = ""
  sensitive   = true
}

variable "atlas_private_key" {
  description = "MongoDB Atlas API private key. Required when create_mongodb is true."
  type        = string
  default     = ""
  sensitive   = true
}

variable "atlas_org_id" {
  description = "MongoDB Atlas organization id. Required when create_mongodb is true."
  type        = string
  default     = ""
}

variable "mongodb_project_name" {
  description = "Atlas project name when create_mongodb is true. Match your existing project to import it."
  type        = string
  default     = "furb-logistics-package-service"
}

variable "mongodb_cluster_name" {
  description = "Atlas M0 cluster name when create_mongodb is true."
  type        = string
  default     = "package"
}

variable "mongodb_database_name" {
  description = "Default database used to build the connection URI."
  type        = string
  default     = "package_db"
}

variable "mongodb_db_username" {
  description = "Atlas database user when create_mongodb is true."
  type        = string
  default     = "package_app"
}

variable "mongodb_db_password" {
  description = "Atlas database user password. Empty generates a random one; set the existing password to import."
  type        = string
  default     = ""
  sensitive   = true
}

variable "mongodb_atlas_region" {
  description = "Atlas region name for the TENANT/AWS backing provider."
  type        = string
  default     = "US_EAST_1"
}

variable "mongodb_ip_access_list" {
  description = "CIDR blocks allowed to reach the Atlas cluster."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
