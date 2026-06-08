terraform {
  required_version = ">= 1.5"

  required_providers {
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      version = "~> 1.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
