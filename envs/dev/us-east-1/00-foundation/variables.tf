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

variable "owner" {
  description = "Owning team."
  type        = string
  default     = "platform"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.10.0.0/16"
}

variable "az_count" {
  description = "Number of AZs used by public/private subnets."
  type        = number
  default     = 2
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway for private subnet egress. Disabled by default to reduce cost."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Create a single NAT Gateway when NAT is enabled."
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN. If empty, ALB exposes HTTP only."
  type        = string
  default     = ""
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecs_instance_type" {
  description = "EC2 instance type used by ECS."
  type        = string
  default     = "t3.micro"
}

variable "ecs_min_size" {
  description = "Minimum EC2 instances in the ECS Auto Scaling Group."
  type        = number
  default     = 1
}

variable "ecs_max_size" {
  description = "Maximum EC2 instances in the ECS Auto Scaling Group."
  type        = number
  default     = 1
}

variable "ecs_desired_capacity" {
  description = "Desired EC2 instances in the ECS Auto Scaling Group."
  type        = number
  default     = 1
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights. Disabled by default to reduce cost."
  type        = bool
  default     = false
}
