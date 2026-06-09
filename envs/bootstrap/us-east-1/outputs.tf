output "state_bucket_name" {
  description = "S3 bucket used by Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "ecr_repository_urls" {
  description = "Map of service name to its shared ECR repository URL."
  value       = { for name, repo in aws_ecr_repository.service : name => repo.repository_url }
}
