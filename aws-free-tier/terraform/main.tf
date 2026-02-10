# ============================================
# AWS Free Tier Infrastructure
# Portfolio Website + Serverless API
# ============================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Backend configuration for state management
  # Uncomment after creating S3 bucket and DynamoDB table
  # backend "s3" {
  #   bucket         = "montero-terraform-state"
  #   key            = "free-tier/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
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
# S3 Bucket for Static Website
# ============================================

resource "aws_s3_bucket" "portfolio_website" {
  bucket = "${var.project_name}-portfolio-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "Portfolio Website"
    Type = "Static Website"
  }
}

resource "aws_s3_bucket_public_access_block" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portfolio_website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.portfolio_website]
}

# ============================================
# CloudFront Distribution (CDN)
# ============================================

resource "aws_cloudfront_origin_access_identity" "portfolio" {
  comment = "Portfolio Website OAI"
}

resource "aws_cloudfront_distribution" "portfolio_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Portfolio Website CDN"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # North America and Europe only

  origin {
    domain_name = aws_s3_bucket.portfolio_website.bucket_regional_domain_name
    origin_id   = "S3-Portfolio"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Portfolio"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "Portfolio CDN"
  }
}

# ============================================
# DynamoDB Table
# ============================================

resource "aws_dynamodb_table" "visitor_counter" {
  name           = "${var.project_name}-visitor-counter"
  billing_mode   = "PAY_PER_REQUEST" # Free tier eligible
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "Visitor Counter"
    Type = "Serverless"
  }
}

# ============================================
# Lambda Function - Visitor Counter
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

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda.zip"
}

resource "aws_lambda_function" "visitor_counter" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-visitor-counter"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128

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
# API Gateway
# ============================================

resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "${var.project_name}-visitor-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["*"]
  }

  tags = {
    Name = "Visitor API"
  }
}

resource "aws_apigatewayv2_stage" "visitor_api" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "Visitor API Stage"
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id               = aws_apigatewayv2_api.visitor_api.id
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.visitor_counter.invoke_arn
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
# CloudWatch Log Groups
# ============================================

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.visitor_counter.function_name}"
  retention_in_days = 7 # Free tier: 5GB storage

  tags = {
    Name = "Lambda Logs"
  }
}

# ============================================
# CloudWatch Dashboard
# ============================================

resource "aws_cloudwatch_dashboard" "portfolio_dashboard" {
  dashboard_name = "${var.project_name}-portfolio-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Lambda Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Lambda Errors" }],
            [".", "Duration", { stat = "Average", label = "Lambda Duration (ms)" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Lambda Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/DynamoDB", "UserErrors", { stat = "Sum" }],
            [".", "ConsumedReadCapacityUnits", { stat = "Sum" }],
            [".", "ConsumedWriteCapacityUnits", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "DynamoDB Metrics"
        }
      }
    ]
  })
}
