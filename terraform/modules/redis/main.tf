resource "aws_elasticache_subnet_group" "this" {
  name = "${var.project_name}-${var.environment}-redis"

  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_cloudwatch_log_group" "slow_log" {
  name              = "/aws/elasticache/${var.project_name}/${var.environment}/slow-log"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-slow-log"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_cloudwatch_log_group" "engine_log" {
  name              = "/aws/elasticache/${var.project_name}/${var.environment}/engine-log"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-engine-log"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.project_name}-${var.environment}"
  description          = "${var.project_name}-${var.environment} Redis cluster"

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters = 1

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = var.security_group_ids

  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  transit_encryption_enabled = var.transit_encryption_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled

  snapshot_retention_limit = var.snapshot_retention_limit

  apply_immediately = var.apply_immediately

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis"
    Environment = var.environment
    Project     = var.project_name
  }
}