variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for ECS tasks"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arns" {
  description = "IAM task roles by service"
  type        = map(string)
  default     = {}
}

variable "services" {
  description = "ECS services configuration"

  type = map(object({
    image          = string
    cpu            = number
    memory         = number
    container_port = number
    desired_count  = number

    environment = optional(map(string), {})

    secrets = optional(map(string), {})

    health_check = optional(object({
      command      = list(string)
      interval     = number
      timeout      = number
      retries      = number
      start_period = number
    }), null)
  }))
}