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

variable "ssm_root_prefix" {
  description = "Root SSM path for logistic contracts."
  type        = string
  default     = "/logistic"
}

variable "alarm_actions" {
  description = "SNS topics or other actions notified by DLQ alarms."
  type        = list(string)
  default     = []
}
