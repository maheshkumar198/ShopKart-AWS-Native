resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-subnet-group"
  }
}



resource "aws_db_instance" "this" {
  identifier = var.name

  engine         = "postgres"
  engine_version = "16"

  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = var.database_name
  username = var.username

  # AWS generates and manages the master password
  # in AWS Secrets Manager.
  manage_master_user_password = true

  port = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  
  vpc_security_group_ids = var.security_group_ids

  publicly_accessible = false

  storage_encrypted = true

  snapshot_identifier = var.snapshot_identifier

  maintenance_window = "sun:04:00-sun:05:00"

  auto_minor_version_upgrade = true

  copy_tags_to_snapshot = true

  multi_az = false

  deletion_protection = false

  skip_final_snapshot = true

  tags = {
    Name = var.name
  }
}