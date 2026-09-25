variable "security_groups_ids" {
  type = list(string)
  description = "Security groups for the ALB"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "Subnet id for the ALB"
}

variable "name" {
  description = "Application name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}