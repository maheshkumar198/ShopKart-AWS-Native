terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket       = "shopkart-aws-native-tf-54321123123213"
    key          = "terraform/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name = "shopkart-dev"

  vpc_cidr = "10.0.0.0/16"

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

module "security_groups" {
  source = "../../modules/security-groups"

  name   = "shopkart-dev"
  vpc_id = module.vpc.vpc_id
}


module "rds" {
  source = "../../modules/rds"

  name                = "shopkart-dev-postgres"
  snapshot_identifier = "shopkart-dev-postgres-snapshot" # Optional: Specify a snapshot identifier to restore from an existing snapshot. If you want to create a new RDS instance without restoring from a snapshot, you can remove this line or set it to null.
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_ids  = [module.security_groups.rds_security_group_id]
  instance_class      = "db.t3.micro"
  database_name       = "shopkart"
  username            = "shopkart"
}

module "iam" {
  source = "../../modules/iam"

  name = "shopkart-dev"
}

module "ecs" {
  source = "../../modules/ecs"

  project_name = "shopkart"
  environment  = "dev"
  aws_region   = "ap-south-1"

  subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [module.security_groups.ecs_security_group_id]


  execution_role_arn = module.iam.ecs_execution_role_arn

  task_role_arns = {
    auth-service    = module.iam.auth_task_role_arn
    catalog-service = module.iam.catalog_task_role_arn
    order-service   = module.iam.order_task_role_arn
    frontend        = module.iam.frontend_task_role_arn
  }

  services = {
    auth-service = {
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/auth-service:latest"
      cpu            = 256
      memory         = 512
      container_port = 3001
      desired_count  = 1

      environment = {
        NODE_ENV = "production"
      }

      health_check = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:3001/health || exit 1"
        ]

        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 10
      }
    }

    catalog-service = {
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/catalog-service:latest"
      cpu            = 256
      memory         = 512
      container_port = 3002
      desired_count  = 1
    }

    order-service = {
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/order-service:latest"
      cpu            = 256
      memory         = 512
      container_port = 3003
      desired_count  = 1

      environment = {
        NODE_ENV = "production"
      }
    }

    frontend = {
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/frontend:latest"
      cpu            = 256
      memory         = 512
      container_port = 80
      desired_count  = 1
    }


  }
}

module "alb" {
  source = "../../modules/alb"

  name = "shopkart-dev"

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  security_groups_ids = [module.security_groups.alb_security_group_id]

}

