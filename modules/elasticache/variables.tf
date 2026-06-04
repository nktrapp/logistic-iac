variable "name_prefix" {
  description = "Stable prefix used in AWS resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC id."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets used by the Redis subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to Redis."
  type        = list(string)
}

variable "secret_name" {
  description = "Secrets Manager secret name."
  type        = string
}

variable "node_type" {
  description = "Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "parameter_group_name" {
  description = "Redis parameter group name."
  type        = string
  default     = "default.redis7"
}

variable "port" {
  description = "Redis port."
  type        = number
  default     = 6379
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
