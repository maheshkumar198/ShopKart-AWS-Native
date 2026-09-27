variable "name" {
  description = "Project/environment name"
  type        = string
}

variable "rds_master_secret_arn" {
  type = string
}

variable "jwt_secret_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "order_queue_arn" {
  type = string
}

variable "order_events_topic_arn" {
  type = string
}