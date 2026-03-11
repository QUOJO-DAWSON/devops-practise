# ============================================
# AWS Free Tier Infrastructure
# Portfolio Website (S3 + CloudFront) + Serverless Visitor API
# Option A: Private S3 (CloudFront OAC only)
# Region: us-east-2
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOps-Portfolio"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "QUOJO-DAWSON"
      Account     = "montero"
    }
  }
}

# ============================================
# Data Sources
# ============================================

data "aws_caller_identity" "current" {}

# ============================================
# S3 Bucket (PRIVATE)
# NOTE: Security controls live in security.tf (no duplicates here)
# ============================================

resource "aws_s3_bucket" "portfolio_website" {
  bucket = "${var.project_name}-portfolio-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "Portfolio Website"
    Type = "Static Website via CloudFront"
  }
}

# ============================================
# CloudFront OAC
# ============================================

resource "aws_cloudfront_origin_access_control" "portfolio_oac" {
  name                              = "${var.project_name}-portfolio-oac"
  description                       = "OAC for private S3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ============================================
# CloudFront Distribution
# IMPORTANT: Keep s3_origin_config but set OriginAccessIdentity to ""
# This is what actually detaches the old OAI so Terraform can delete it.
# ============================================

resource "aws_cloudfront_distribution" "portfolio_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Portfolio Website CDN"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # Custom domain aliases
  aliases = [
    "gdawsonkesson.com",
    "www.gdawsonkesson.com"
  ]

  origin {
    domain_name              = aws_s3_bucket.portfolio_website.bucket_regional_domain_name
    origin_id                = "S3-Portfolio"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-Portfolio"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # SPA routing support
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Use custom SSL certificate
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.portfolio.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "Portfolio CDN"
  }
}

# ============================================
# Bucket Policy (Allow CloudFront OAC Only)
# NOTE: NO depends_on here to avoid undeclared reference errors.
# ============================================

resource "aws_s3_bucket_policy" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.portfolio_website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.portfolio_cdn.id}"
          }
        }
      }
    ]
  })
}

# ============================================
# DynamoDB Table (Visitor Counter)
# ============================================

resource "aws_dynamodb_table" "visitor_counter" {
  name         = "${var.project_name}-visitor-counter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "Visitor Counter"
  }
}

# ============================================
# IAM Role for Lambda
# ============================================

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.visitor_counter.arn
      }
    ]
  })
}

# ============================================
# Lambda Function
# ============================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda.zip"
}

resource "aws_lambda_function" "visitor_counter" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-visitor-counter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 10
  memory_size      = 128
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_counter.name
    }
  }

  tags = {
    Name = "Visitor Counter Lambda"
  }
}

# ============================================
# API Gateway HTTP API
# ============================================

resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "${var.project_name}-visitor-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "visitor_api" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.visitor_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.visitor_counter.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_count" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}

# ============================================
# CloudWatch Logs
# ============================================

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.visitor_counter.function_name}"
  retention_in_days = 7
}