variable "name_prefix" {
  description = "Value used as the security group name_prefix."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC id where the security group is created."
  type        = string
}

variable "ingress_rules" {
  description = "Ingress rules. Each rule may source from cidr_blocks and/or source_security_group_ids."
  type = list(object({
    description               = optional(string)
    from_port                 = number
    to_port                   = number
    protocol                  = string
    cidr_blocks               = optional(list(string), [])
    source_security_group_ids = optional(list(string), [])
  }))
  default = []
}

variable "egress_rules" {
  description = "Egress rules. Each rule may target cidr_blocks and/or source_security_group_ids."
  type = list(object({
    description               = optional(string)
    from_port                 = number
    to_port                   = number
    protocol                  = string
    cidr_blocks               = optional(list(string), [])
    source_security_group_ids = optional(list(string), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to the security group. Pass the Name tag here when needed."
  type        = map(string)
  default     = {}
}
