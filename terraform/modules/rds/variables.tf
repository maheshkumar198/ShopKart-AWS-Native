variable "name" {
  description = "RDS instance identifier"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the RDS instance"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "shopkart"
}

variable "username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "shopkart"
}

variable "snapshot_identifier" {
  description = "Optional RDS snapshot to restore from"
  type        = string
  default     = null
}