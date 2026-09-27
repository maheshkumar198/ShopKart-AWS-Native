output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "service_names" {
  description = "ECS service names"
  value = {
    for name, service in aws_ecs_service.this :
    name => service.name
  }
}

output "task_definition_arns" {
  description = "Task definition ARNs"
  value = {
    for name, task in aws_ecs_task_definition.this :
    name => task.arn
  }
}

output "log_group_names" {
  description = "CloudWatch log groups"
  value = {
    for name, log_group in aws_cloudwatch_log_group.this :
    name => log_group.name
  }
}

output "scale_out_policy_arns" {
  value = {
    for service, policy in aws_appautoscaling_policy.ecs_scale_out :
    service => policy.arn
  }
}

output "scale_in_policy_arns" {
  value = {
    for service, policy in aws_appautoscaling_policy.ecs_scale_in :
    service => policy.arn
  }
}