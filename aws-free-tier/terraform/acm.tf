# ACM Certificate for Custom Domain (must be in us-east-1 for CloudFront)
resource "aws_acm_certificate" "portfolio" {
  provider = aws.us_east_1

  domain_name       = "gdawsonkesson.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.gdawsonkesson.com"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "gdawsonkesson.com"
  }
}

# DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.portfolio.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "portfolio" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.portfolio.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

output "certificate_arn" {
  value       = aws_acm_certificate.portfolio.arn
  description = "ARN of the SSL certificate"
}