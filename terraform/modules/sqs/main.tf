resource "aws_sqs_queue" "dlq" {
  name = "${var.project_name}-${var.environment}-order-dlq"

  message_retention_seconds = var.message_retention_seconds

  sqs_managed_sse_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-order-dlq"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_sqs_queue" "order_queue" {
  name = "${var.project_name}-${var.environment}-order-queue"

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds

  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-order-queue"
    Environment = var.environment
    Project     = var.project_name
  }
}