variable "name_prefix" {
  description = "Prefix used in AWS resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC id."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets used by the ALB."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN. When empty, only HTTP is enabled."
  type        = string
  default     = ""
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the public ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
