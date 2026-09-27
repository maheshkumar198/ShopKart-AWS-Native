output "order_events_topic_arn" {
  value = aws_sns_topic.order_events.arn
}

output "order_events_topic_name" {
  value = aws_sns_topic.order_events.name
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}