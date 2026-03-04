# DNS A Records for Custom Domain

# Root domain (gdawsonkesson.com)
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "gdawsonkesson.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# WWW subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.gdawsonkesson.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

output "custom_domain_url" {
  value       = "https://gdawsonkesson.com"
  description = "Your custom domain URL"
}

output "www_domain_url" {
  value       = "https://www.gdawsonkesson.com"
  description = "WWW subdomain URL"
}