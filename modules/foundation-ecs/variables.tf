variable "name_prefix" {
  description = "Prefix used in AWS resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC id."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets where ECS EC2 instances run."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group allowed to reach dynamic ECS host ports."
  type        = string
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights."
  type        = bool
  default     = false
}

variable "ecs_instance_type" {
  description = "EC2 instance type used by ECS capacity provider."
  type        = string
  default     = "t3.small"
}

variable "ecs_instance_min_size" {
  description = "Minimum EC2 instances in the ECS ASG."
  type        = number
  default     = 1
}

variable "ecs_instance_max_size" {
  description = "Maximum EC2 instances in the ECS ASG."
  type        = number
  default     = 2
}

variable "ecs_instance_desired_capacity" {
  description = "Desired EC2 instances in the ECS ASG."
  type        = number
  default     = 1
}

variable "ecs_instance_volume_size" {
  description = "Root EBS volume size in GiB. Must be >= the ECS-optimized AMI snapshot size (30 GiB for Amazon Linux 2023)."
  type        = number
  default     = 30
}

variable "ecs_optimized_ami_ssm_parameter" {
  description = "Public SSM parameter that resolves to ECS-optimized AMI id."
  type        = string
  default     = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
