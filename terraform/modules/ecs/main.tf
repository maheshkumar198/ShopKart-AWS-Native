resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "this" {
  for_each = var.services

  name              = "/ecs/${var.project_name}/${var.environment}/${each.key}"
  retention_in_days = 30

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = each.key
  }
}

resource "aws_ecs_task_definition" "this" {
  for_each = var.services

  family                   = "${var.project_name}-${var.environment}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = each.value.cpu
  memory = each.value.memory

  execution_role_arn = var.execution_role_arn

  task_role_arn = lookup(
    var.task_role_arns,
    each.key,
    null
  )

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = each.value.image
      essential = true

      portMappings = [
        {
          containerPort = each.value.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for name, value in each.value.environment : {
          name  = name
          value = value
        }
      ]

      secrets = [
        for name, value_from in each.value.secrets : {
          name      = name
          valueFrom = value_from
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this[each.key].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = each.key
  }
}

resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = "${var.project_name}-${var.environment}-${each.key}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.key].arn

  desired_count = each.value.desired_count

  launch_type = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  enable_execute_command = true

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = each.key
  }
}