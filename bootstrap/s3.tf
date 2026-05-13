provider "aws" {
  region = "us-east-1"
}

# 1. Create the S3 bucket for state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "selmonosky-bootstrap-bucket" 
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

# 2. Enable versioning to allow state recovery
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "ENABLED"
  }
}

# 3. Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Block all public access to protect sensitive data
resource "aws_s3_bucket_public_access_block" "state_public_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}