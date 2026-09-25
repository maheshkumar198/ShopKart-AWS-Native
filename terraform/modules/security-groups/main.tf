resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for ShopKart ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}


resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-sg"
  description = "Security group for ShopKart ECS services"
  vpc_id      = var.vpc_id

  # Frontend traffic from ALB
  ingress {
    description     = "Frontend from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Auth service
  ingress {
    description     = "Auth service"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Catalog service
  ingress {
    description     = "Catalog service"
    from_port       = 3002
    to_port         = 3002
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Order service
  ingress {
    description     = "Order service"
    from_port       = 3003
    to_port         = 3003
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Service-to-service communication
  ingress {
    description     = "ECS service communication"
    from_port       = 3000
    to_port         = 65535
    protocol        = "tcp"
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ecs-sg"
  }
}


resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Security group for ShopKart RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}


resource "aws_security_group" "redis" {
  name        = "${var.name}-redis-sg"
  description = "Security group for ShopKart ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-redis-sg"
  }
}