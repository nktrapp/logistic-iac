provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}
