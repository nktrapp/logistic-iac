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
  default     = "package-team"
}

variable "ssm_root_prefix" {
  description = "Root SSM prefix where the data contract is published. 30-services reads from the same root."
  type        = string
  default     = "/logistic"
}

# --- MongoDB Atlas (data-mongodb-atlas module) ---

variable "atlas_public_key" {
  description = "MongoDB Atlas API public key."
  type        = string
  default     = ""
  sensitive   = true
}

variable "atlas_private_key" {
  description = "MongoDB Atlas API private key."
  type        = string
  default     = ""
  sensitive   = true
}

variable "atlas_org_id" {
  description = "MongoDB Atlas organization id."
  type        = string
  default     = ""
}

variable "mongodb_project_name" {
  description = "Atlas project name. Match your existing project to import it."
  type        = string
  default     = "furb-logistics-package-service"
}

variable "mongodb_cluster_name" {
  description = "Atlas M0 cluster name."
  type        = string
  default     = "package"
}

variable "mongodb_database_name" {
  description = "Default database used to build the connection URI."
  type        = string
  default     = "package_db"
}

variable "mongodb_db_username" {
  description = "Atlas database user."
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
