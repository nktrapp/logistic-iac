locals {
  tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    Owner       = var.owner
    ManagedBy   = "terraform"
    Layer       = "bootstrap"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  tags = merge(local.tags, {
    Name = var.state_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.tags, {
    Name = var.lock_table_name
  })
}

resource "aws_ecr_repository" "service" {
  for_each = toset(var.service_names)

  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.tags, {
    Name    = "${var.project_name}/${each.value}"
    Service = each.value
  })
}

resource "aws_ecr_lifecycle_policy" "service" {
  for_each = aws_ecr_repository.service

  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${var.ecr_keep_last_images} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_keep_last_images
      }
      action = {
        type = "expire"
      }
    }]
  })
}
