output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "auth_task_role_arn" {
  value = aws_iam_role.auth_task.arn
}

output "catalog_task_role_arn" {
  value = aws_iam_role.catalog_task.arn
}

output "order_task_role_arn" {
  value = aws_iam_role.order_task.arn
}

output "frontend_task_role_arn" {
  value = aws_iam_role.frontend_task.arn
}

output "order_processor_lambda_role_arn" {
  value = aws_iam_role.order_processor_lambda.arn
}