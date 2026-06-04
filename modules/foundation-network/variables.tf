variable "name_prefix" {
  description = "Prefix used in AWS resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones/subnet pairs."
  type        = number
  default     = 2
}

variable "create_nat_gateway" {
  description = "Create NAT gateway(s) for private subnet internet egress."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
