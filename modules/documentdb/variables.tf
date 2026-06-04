variable "name_prefix" {
  description = "Stable prefix used in AWS resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC id."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets used by the DocumentDB subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to DocumentDB."
  type        = list(string)
}

variable "master_username" {
  description = "DocumentDB master username."
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "DocumentDB master password."
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Application database name."
  type        = string
}

variable "database_secret_key" {
  description = "Secret JSON key containing the database-specific MongoDB URI."
  type        = string
}

variable "secret_name" {
  description = "Secrets Manager secret name."
  type        = string
}

variable "instance_count" {
  description = "Number of DocumentDB instances."
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "DocumentDB instance class."
  type        = string
  default     = "db.t3.medium"
}

variable "parameter_group_family" {
  description = "DocumentDB parameter group family."
  type        = string
  default     = "docdb5.0"
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 1
}

variable "preferred_backup_window" {
  description = "Preferred backup window."
  type        = string
  default     = "03:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot on destroy."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
