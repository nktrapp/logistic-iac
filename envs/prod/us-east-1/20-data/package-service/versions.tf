terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "logistic-iac-terraform-state"
    key          = "prod/us-east-1/data/package-service/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.0"
    }
  }
}
