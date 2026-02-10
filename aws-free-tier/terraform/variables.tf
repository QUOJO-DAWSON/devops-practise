# ============================================
# Terraform Variables
# ============================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-2" # Ohio
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "montero-devops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "enable_cloudfront" {
  description = "Enable CloudFront CDN for website"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and dashboards"
  type        = bool
  default     = true
}
