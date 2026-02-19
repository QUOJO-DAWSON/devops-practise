# Security Enhancements

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Lifecycle Policy
resource "aws_s3_bucket_lifecycle_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
