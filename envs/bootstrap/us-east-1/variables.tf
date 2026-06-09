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

variable "service_names" {
  description = "Services that get a shared, environment-agnostic ECR repository."
  type        = list(string)
  default     = ["logistics-service", "package-service"]
}

variable "ecr_keep_last_images" {
  description = "Number of images kept per ECR repository before older ones expire. Repos are shared across dev and prod; with natively-compiled ~80MB images, 3 is the chosen retention."
  type        = number
  default     = 3
}

variable "ecr_scan_on_push" {
  description = "Whether ECR scans images for vulnerabilities on push."
  type        = bool
  default     = true
}
