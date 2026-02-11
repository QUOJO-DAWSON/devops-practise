# ============================================
# Terraform Outputs
# ============================================

output "website_bucket_name" {
  description = "S3 bucket name for website hosting"
  value       = aws_s3_bucket.portfolio_website.id
}

output "website_url" {
  description = "Website URL (S3)"
  value       = "http://${aws_s3_bucket_website_configuration.portfolio_website.website_endpoint}"
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.portfolio_cdn.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.portfolio_cdn.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.visitor_api.api_endpoint
}

output "visitor_counter_api" {
  description = "Full visitor counter API URL"
  value       = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/count"
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.visitor_counter.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.portfolio_dashboard.dashboard_name}"
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    website_url     = "https://${aws_cloudfront_distribution.portfolio_cdn.domain_name}"
    api_url         = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/count"
    s3_bucket       = aws_s3_bucket.portfolio_website.id
    lambda_function = aws_lambda_function.visitor_counter.function_name
    dynamodb_table  = aws_dynamodb_table.visitor_counter.name
    cost_estimate   = "$0.00 (Free Tier)"
  }
}
