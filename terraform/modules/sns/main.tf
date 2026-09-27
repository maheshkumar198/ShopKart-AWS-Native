resource "aws_sns_topic" "order_events" {
  name = "${var.project_name}-${var.environment}-order-events"

  tags = {
    Name        = "${var.project_name}-${var.environment}-order-events"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Name        = "${var.project_name}-${var.environment}-alerts"
    Environment = var.environment
    Project     = var.project_name
  }
}