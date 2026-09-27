variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "engine_version" {
  type    = string
  default = "7.1"
}

variable "port" {
  type    = number
  default = 6379
}

variable "snapshot_retention_limit" {
  type    = number
  default = 1
}

variable "automatic_failover_enabled" {
  type    = bool
  default = false
}

variable "multi_az_enabled" {
  type    = bool
  default = false
}

variable "transit_encryption_enabled" {
  type    = bool
  default = true
}

variable "at_rest_encryption_enabled" {
  type    = bool
  default = true
}

variable "apply_immediately" {
  type    = bool
  default = true
}