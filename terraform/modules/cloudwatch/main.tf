resource "aws_cloudwatch_metric_alarm" "order_dlq" {
  alarm_name = "${var.project_name}-${var.environment}-order-dlq"

  alarm_description = "Alarm when messages are present in the Order DLQ"

  namespace = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = var.dlq_queue_name
  }

  statistic = "Maximum"
  period    = 60
  evaluation_periods = 1

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  treat_missing_data = "notBreaching"

  alarm_actions = [
    var.alert_topic_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  for_each = var.ecs_service_names

  alarm_name = "${var.project_name}-${var.environment}-${each.key}-ecs-cpu-high"

  alarm_description = "ECS CPU utilization is high for ${each.key}"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = each.value
  }

  statistic = "Average"

  period = 300

  evaluation_periods = 2

  comparison_operator = "GreaterThanThreshold"
  threshold           = 80

  treat_missing_data = "notBreaching"

  alarm_actions = [
    var.alert_topic_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  for_each = var.ecs_service_names

  alarm_name = "${var.project_name}-${var.environment}-${each.key}-ecs-memory-high"

  alarm_description = "ECS memory utilization is high for ${each.key}"

  namespace   = "AWS/ECS"
  metric_name = "MemoryUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = each.value
  }

  statistic = "Average"

  period = 300

  evaluation_periods = 2

  comparison_operator = "GreaterThanThreshold"
  threshold           = 80

  treat_missing_data = "notBreaching"

  alarm_actions = [
    var.alert_topic_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_scale_out" {
  for_each = var.ecs_service_names

  alarm_name = "${var.project_name}-${var.environment}-${each.key}-cpu-scale-out"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = each.value
  }

  statistic = "Average"
  period    = 60

  evaluation_periods = 1

  comparison_operator = "GreaterThanThreshold"
  threshold           = 60

  alarm_actions = [
    var.scale_out_policy_arns[each.key]
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_scale_in" {
  for_each = var.ecs_service_names

  alarm_name = "${var.project_name}-${var.environment}-${each.key}-cpu-scale-in"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = each.value
  }

  statistic          = "Average"
  period             = 60
  evaluation_periods = 1

  comparison_operator = "LessThanThreshold"
  threshold           = 40

  treat_missing_data = "notBreaching"

  alarm_actions = [
    var.scale_in_policy_arns[each.key]
  ]
}