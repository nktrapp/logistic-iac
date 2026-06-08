provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}

# Inert until create_mongodb = true. Credentials are only used when the module
# instantiates Atlas resources.
provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

# Inert until create_redis = true.
provider "rediscloud" {
  api_key    = var.rediscloud_api_key
  secret_key = var.rediscloud_secret_key
}
