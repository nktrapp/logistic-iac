provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    cloudwatch     = var.ministack_endpoint
    secretsmanager = var.ministack_endpoint
    sqs            = var.ministack_endpoint
    ssm            = var.ministack_endpoint
  }

  default_tags {
    tags = local.tags
  }
}
