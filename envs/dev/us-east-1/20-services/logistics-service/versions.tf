terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "logistic-iac-terraform-state"
    key            = "dev/us-east-1/services/logistics-service/terraform.tfstate"
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
