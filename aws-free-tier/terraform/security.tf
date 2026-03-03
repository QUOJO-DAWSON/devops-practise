# ============================================
# S3 Security + Hygiene (Option A)
# Keep the S3 bucket PRIVATE (CloudFront OAC only)
# ============================================

resource "aws_s3_bucket_public_access_block" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  rule {
    id     = "cleanup-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}