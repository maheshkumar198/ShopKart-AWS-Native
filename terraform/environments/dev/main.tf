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

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name = "shopkart"
  environment  = "dev"

  dlq_queue_name = module.sqs.dlq_name

  alert_topic_arn = module.sns.alerts_topic_arn

  ecs_cluster_name = "shopkart-dev"

  ecs_service_names = {
    frontend        = "shopkart-dev-frontend"
    auth-service    = "shopkart-dev-auth-service"
    catalog-service = "shopkart-dev-catalog-service"
    order-service   = "shopkart-dev-order-service"
  }
  
  scale_out_policy_arns = module.ecs.scale_out_policy_arns
  scale_in_policy_arns  = module.ecs.scale_in_policy_arns

}

module "sns" {
  source = "../../modules/sns"

  project_name = "shopkart"
  environment  = "dev"
}

module "order_processor" {
  source = "../../modules/lambda-order-processor"

  project_name = "shopkart"
  environment  = "dev"

  execution_role_arn = module.iam.order_processor_lambda_role_arn
  sns_topic_arn = module.sns.order_events_topic_arn
  sqs_queue_arn = module.sqs.order_queue_arn

  lambda_zip_path = "${path.root}/../../modules/lambda-order-processor/order-processor.zip"
}

module "sqs" {
  source = "../../modules/sqs"

  project_name = "shopkart"
  environment  = "dev"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600
  max_receive_count          = 3
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

  name                  = "shopkart-dev"
  rds_master_secret_arn = module.rds.master_user_secret_arn
  jwt_secret_arn        = "arn:aws:secretsmanager:ap-south-1:905179308072:secret:jwt-secret-PamF8G"
  environment           = "production"
  order_queue_arn = module.sqs.order_queue_arn
  order_events_topic_arn = module.sns.order_events_topic_arn

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

  load_balancer_target_groups = {
    frontend        = module.alb.frontend_target_group_arn
    auth-service    = module.alb.auth_target_group_arn
    catalog-service = module.alb.catalog_target_group_arn
    order-service   = module.alb.order_target_group_arn
  }
  ecs_cluster_name = "shopkart-dev"

  ecs_service_names = {
    frontend        = "shopkart-dev-frontend"
    auth-service    = "shopkart-dev-auth-service"
    catalog-service = "shopkart-dev-catalog-service"
    order-service   = "shopkart-dev-order-service"
  }
  
  services = {
    auth-service = {
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/ecs-auth-service:latest"
      cpu            = 256
      memory         = 512
      container_port = 3001
      desired_count  = 1

      environment = {
        NODE_ENV = "production"
        DB_HOST  = module.rds.endpoint
        DB_PORT  = module.rds.port
        DB_NAME  = module.rds.database_name

      }
      secrets = {
        DB_PASSWORD = "${module.rds.master_user_secret_arn}:password::"
        DB_USERNAME = "${module.rds.master_user_secret_arn}:username::"
        JWT_SECRET  = "arn:aws:secretsmanager:ap-south-1:905179308072:secret:jwt-secret-PamF8G:JWT_SECRET::"
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
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/ecs-catalog-service:latest"
      cpu            = 256
      memory         = 512
      container_port = 3002
      desired_count  = 1

      environment = {
        NODE_ENV  = "production"
        DB_HOST   = module.rds.endpoint
        DB_PORT   = module.rds.port
        DB_NAME   = module.rds.database_name
        REDIS_URL = "rediss://${module.redis.primary_endpoint_address}:${module.redis.port}"
      }
      secrets = {
        DB_PASSWORD = "${module.rds.master_user_secret_arn}:password::"
        DB_USERNAME = "${module.rds.master_user_secret_arn}:username::"
        JWT_SECRET  = "arn:aws:secretsmanager:ap-south-1:905179308072:secret:jwt-secret-PamF8G:JWT_SECRET::"
      }

    }

    order-service = {
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/ecs-order-service:latest"
      cpu            = 256
      memory         = 512
      container_port = 3003
      desired_count  = 1

       environment = {
        NODE_ENV  = "production"
        DB_HOST   = module.rds.endpoint
        DB_PORT   = module.rds.port
        DB_NAME   = module.rds.database_name
        REDIS_URL = "rediss://${module.redis.primary_endpoint_address}:${module.redis.port}"
        CATALOG_URL = "http://${module.alb.alb_dns_name}/api"
        ORDER_QUEUE_URL = module.sqs.order_queue_url
      }
      secrets = {
        DB_PASSWORD = "${module.rds.master_user_secret_arn}:password::"
        DB_USERNAME = "${module.rds.master_user_secret_arn}:username::"
        JWT_SECRET  = "arn:aws:secretsmanager:ap-south-1:905179308072:secret:jwt-secret-PamF8G:JWT_SECRET::"
      }

    }

    frontend = {
      image          = "905179308072.dkr.ecr.ap-south-1.amazonaws.com/shopkart/ecs-frontend:latest"
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

module "redis" {
  source = "../../modules/redis"

  project_name = "shopkart"
  environment  = "dev"

  subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [
    module.security_groups.redis_security_group_id
  ]

  node_type      = "cache.t3.micro"
  engine_version = "7.1"

  snapshot_retention_limit = 1

  automatic_failover_enabled = false
  multi_az_enabled           = false

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true

  apply_immediately = true
}

