# ============================================
# Cost Monitoring and Budgets (Optional)
# Default: OFF to keep deployment $0 target
# ============================================

resource "aws_sns_topic" "budget_alerts" {
  count = var.enable_cost_monitoring ? 1 : 0
  name  = "${var.project_name}-budget-alerts"
}

resource "aws_sns_topic_subscription" "budget_email" {
  count     = var.enable_cost_monitoring ? 1 : 0
  topic_arn = aws_sns_topic.budget_alerts[0].arn
  protocol  = "email"
  endpoint  = var.budget_alert_email
}

resource "aws_budgets_budget" "monthly_budget" {
  count = var.enable_cost_monitoring ? 1 : 0

  name         = "${var.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = "5.00"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  time_period_start = "2026-02-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_alert_email]
  }

  cost_types {
    include_tax          = true
    include_subscription = true
    use_blended          = false
  }
}