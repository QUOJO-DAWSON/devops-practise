variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "montero-devops"
}

# Cost monitoring is optional and OFF by default for $0 target
variable "enable_cost_monitoring" {
  description = "Enable AWS Budgets + SNS alerts (OFF by default for $0 deployment)"
  type        = bool
  default     = false
}

variable "budget_alert_email" {
  description = "Email address to receive budget alerts"
  type        = string
  default     = "ufefedawson@gmail.com"
}