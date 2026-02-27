# Cost Monitoring and Budgets

# SNS Topic for Budget Alerts
resource "aws_sns_topic" "budget_alerts" {
  name = "${var.project_name}-budget-alerts"
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "budget_email" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = "dawsonkessongp@gmail.com"
}

# Monthly Budget with Alerts
resource "aws_budgets_budget" "monthly_budget" {
  name              = "${var.project_name}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = "5.00"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-02-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = ["dawsonkessongp@gmail.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = ["dawsonkessongp@gmail.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_email_addresses = ["dawsonkessongp@gmail.com"]
  }

  cost_types {
    include_tax          = true
    include_subscription = true
    use_blended          = false
  }
}

# Cost Allocation Tags
resource "aws_ce_cost_category" "project_category" {
  name         = "${var.project_name}-category"
  rule_version = "CostCategoryExpression.v1"

  rule {
    value = "DevOps-Portfolio"
    rule {
      dimension {
        key           = "RESOURCE_ID"
        match_options = ["CONTAINS"]
        values        = ["montero"]
      }
    }
  }
}
