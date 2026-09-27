resource "aws_cloudwatch_log_group" "order_processor" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-order-processor"
  retention_in_days = 30
}


resource "aws_lambda_function" "order_processor" {
  function_name = "${var.project_name}-${var.environment}-order-processor"

  role = var.execution_role_arn

  runtime = "nodejs22.x"
  handler = "index.handler"

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  timeout     = 30
  memory_size = 256

  environment {
    variables = {
      ENVIRONMENT = var.environment
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.order_processor
  ]
}


resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.order_processor.arn

  batch_size                         = 1
  maximum_batching_window_in_seconds = 0

  function_response_types = [
    "ReportBatchItemFailures"
  ]

  enabled = true
}