output "bucket_name" {
  description = "S3 bucket name (private origin)"
  value       = aws_s3_bucket.portfolio_website.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.portfolio_cdn.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.portfolio_cdn.domain_name
}

output "cloudfront_url" {
  description = "CloudFront URL"
  value       = "https://${aws_cloudfront_distribution.portfolio_cdn.domain_name}"
}

output "api_endpoint" {
  description = "API Gateway base endpoint"
  value       = aws_apigatewayv2_api.visitor_api.api_endpoint
}

output "visitor_counter_api" {
  description = "Visitor counter full endpoint"
  value       = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/count"
}

output "lambda_function_name" {
  description = "Visitor counter lambda name"
  value       = aws_lambda_function.visitor_counter.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.visitor_counter.name
}