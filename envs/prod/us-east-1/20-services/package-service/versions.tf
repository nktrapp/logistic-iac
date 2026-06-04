terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "logistic-iac-terraform-state"
    key            = "prod/us-east-1/services/package-service/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "logistic-iac-terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
