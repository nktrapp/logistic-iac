variable "subscription_name" {
  description = "Redis Cloud Essentials subscription name. Match the existing name to import it."
  type        = string
}

variable "database_name" {
  description = "Redis Cloud database name."
  type        = string
}

variable "plan_name" {
  description = "Essentials plan name. The 30MB plan is the free tier."
  type        = string
  default     = "30MB"
}

variable "cloud_provider" {
  description = "Cloud provider backing the Essentials plan."
  type        = string
  default     = "AWS"
}

variable "region" {
  description = "Region for the Essentials plan (e.g. us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "database_password" {
  description = "Database password. When empty, a random password is generated. Set it to the existing password to import."
  type        = string
  default     = ""
  sensitive   = true
}

variable "data_persistence" {
  description = "Data persistence policy. The free tier supports 'none'."
  type        = string
  default     = "none"
}
