variable "project_name" {
  description = "Project name used in tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "queue_name_prefix" {
  description = "Prefix prepended to physical queue names. Use an empty string for local MiniStack."
  type        = string
  default     = ""
}

variable "ssm_prefix" {
  description = "Base SSM path where queue contract parameters are published."
  type        = string
}

variable "contracts" {
  description = "Map of SQS contract definitions loaded from catalog YAML files."
  type        = map(any)
}

variable "create_ssm_parameters" {
  description = "Whether to publish SSM parameters for the contracts."
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "CloudWatch alarm actions used by DLQ alarms."
  type        = list(string)
  default     = []
}

variable "create_dlq_alarms" {
  description = "Whether to create CloudWatch alarms for DLQs."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
