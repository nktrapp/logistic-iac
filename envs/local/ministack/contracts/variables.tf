variable "aws_region" {
  description = "AWS region used by MiniStack."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "local"
}

variable "project_name" {
  description = "Project name used in tags."
  type        = string
  default     = "logistic"
}

variable "owner" {
  description = "Owning team."
  type        = string
  default     = "local"
}

variable "ministack_endpoint" {
  description = "MiniStack AWS-compatible endpoint."
  type        = string
  default     = "http://ministack:4566"
}

variable "queue_name_prefix" {
  description = "Queue name prefix. Keep empty locally to match application defaults."
  type        = string
  default     = ""
}

variable "ssm_root_prefix" {
  description = "Root SSM path for logistic contracts."
  type        = string
  default     = "/logistic"
}
