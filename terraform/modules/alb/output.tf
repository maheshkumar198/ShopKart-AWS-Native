output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB Route 53 zone ID"
  value       = aws_lb.this.zone_id
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "auth_target_group_arn" {
  value = aws_lb_target_group.auth.arn
}

output "catalog_target_group_arn" {
  value = aws_lb_target_group.catalog.arn
}

output "order_target_group_arn" {
  value = aws_lb_target_group.order.arn
}