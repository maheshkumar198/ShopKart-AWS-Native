output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Database username"
  value       = aws_db_instance.this.username
}


output "master_user_secret_arn" {
  description = "AWS Secrets Manager ARN containing RDS master credentials"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}