variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "dlq_queue_name" {
  type = string
}

variable "alert_topic_arn" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_names" {
  type = map(string)
}

variable "scale_out_policy_arns" {
  type = map(string)
}

variable "scale_in_policy_arns" {
  type = map(string)
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 3
}