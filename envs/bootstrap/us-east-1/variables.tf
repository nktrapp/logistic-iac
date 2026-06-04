variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags."
  type        = string
  default     = "furb-logistics"
}

variable "owner" {
  description = "Owning team."
  type        = string
  default     = "platform"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name used by Terraform remote state."
  type        = string
  default     = "logistic-iac-terraform-state"
}

variable "lock_table_name" {
  description = "DynamoDB table name used by Terraform state locking."
  type        = string
  default     = "logistic-iac-terraform-lock"
}
