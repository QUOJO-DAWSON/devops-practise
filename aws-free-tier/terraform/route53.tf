# Route 53 Hosted Zone for Custom Domain
resource "aws_route53_zone" "main" {
  name = "gdawsonkesson.com"

  tags = {
    Name        = "gdawsonkesson.com"
    Environment = "production"
  }
}

# Output nameservers
output "route53_nameservers" {
  value       = aws_route53_zone.main.name_servers
  description = "Route 53 nameservers to configure in Porkbun"
}

output "route53_zone_id" {
  value       = aws_route53_zone.main.zone_id
  description = "Route 53 hosted zone ID"
}