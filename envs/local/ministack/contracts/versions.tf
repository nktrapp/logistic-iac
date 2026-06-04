terraform {
  required_version = ">= 1.5"

  backend "local" {
    path = "/terraform-state/contracts.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
