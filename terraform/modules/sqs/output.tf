output "order_queue_id" {
  value = aws_sqs_queue.order_queue.id
}

output "order_queue_arn" {
  value = aws_sqs_queue.order_queue.arn
}

output "order_queue_url" {
  value = aws_sqs_queue.order_queue.url
}

output "dlq_id" {
  value = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}

output "dlq_name" {
  value = aws_sqs_queue.dlq.name
}