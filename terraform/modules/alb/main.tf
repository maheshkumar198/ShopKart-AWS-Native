resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups_ids
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = "${var.name}-alb"
  }
}


resource "aws_lb_target_group" "frontend" {
  name        = "${var.name}-frontend"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "${var.name}-frontend-tg"
    Service = "frontend"
  }
}

resource "aws_lb_target_group" "auth" {
  name        = "${var.name}-auth"
  port        = 3001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "${var.name}-auth-tg"
    Service = "auth-service"
  }
}

resource "aws_lb_target_group" "catalog" {
  name        = "${var.name}-catalog"
  port        = 3002
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "${var.name}-catalog-tg"
    Service = "catalog-service"
  }
}

resource "aws_lb_target_group" "order" {
  name        = "${var.name}-order"
  port        = 3003
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "${var.name}-order-tg"
    Service = "order-service"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.frontend.arn
      }
    }
  }
}

resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.http.arn

  priority = 10

  condition {
    path_pattern {
      values = ["/api/auth/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }
}

resource "aws_lb_listener_rule" "catalog" {
  listener_arn = aws_lb_listener.http.arn

  priority = 20

  condition {
    path_pattern {
      values = ["/api/products*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalog.arn
  }
}

resource "aws_lb_listener_rule" "order" {
  listener_arn = aws_lb_listener.http.arn

  priority = 30

  condition {
    path_pattern {
      values = ["/api/orders*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order.arn
  }
}

resource "aws_lb_listener_rule" "cart" {
  listener_arn = aws_lb_listener.http.arn

  priority = 25

  condition {
    path_pattern {
      values = ["/api/cart*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order.arn
  }
}