variable "atlas_org_id" {
  description = "MongoDB Atlas organization id that owns the project."
  type        = string
}

variable "project_name" {
  description = "Atlas project name. Match the existing project name to import it instead of creating a new one."
  type        = string
}

variable "cluster_name" {
  description = "Atlas cluster name (M0 free tier)."
  type        = string
}

variable "region" {
  description = "Atlas region name for the TENANT/AWS backing provider (e.g. US_EAST_1)."
  type        = string
  default     = "US_EAST_1"
}

variable "database_name" {
  description = "Default database the service connects to. Used to scope the user role and build the URI."
  type        = string
}

variable "db_username" {
  description = "Database user created in the project."
  type        = string
}

variable "db_password" {
  description = "Database user password. When empty, a random password is generated. Set it to the existing password to import."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ip_access_list" {
  description = "CIDR blocks allowed to reach the cluster. ECS tasks run on public subnets with dynamic IPs, so 0.0.0.0/0 is the pragmatic free-tier default."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
