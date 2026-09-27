# ShopKart – AWS-Native Microservices Platform

ShopKart is a production-style e-commerce microservices application deployed on AWS using containers, managed AWS services, Terraform, and GitHub Actions.

The project demonstrates microservices architecture, containerization, Infrastructure as Code, event-driven processing, caching, monitoring, autoscaling, failure handling, and CI/CD.

---

## Architecture
<img width="1536" height="1024" alt="ChatGPT Image Sep 27, 2026, 10_11_05 PM" src="https://github.com/user-attachments/assets/3661a7a3-bd40-4bd9-b573-dc160c3152ec" />


## AWS Services

* Amazon VPC
* Amazon ECS / AWS Fargate
* Application Load Balancer
* Amazon ECR
* Amazon RDS PostgreSQL
* Amazon ElastiCache Redis
* Amazon SQS
* Amazon SQS Dead Letter Queue
* AWS Lambda
* Amazon SNS
* Amazon CloudWatch
* AWS Secrets Manager
* AWS IAM
* NAT Gateway
* Internet Gateway

---

## Application Services

| Service         | Port | Purpose                              |
| --------------- | ---: | ------------------------------------ |
| Frontend        |   80 | Web application                      |
| Auth Service    | 3001 | User registration and authentication |
| Catalog Service | 3002 | Product management and catalog       |
| Order Service   | 3003 | Cart and order processing            |

---

## Request Flow

The Application Load Balancer routes requests to the appropriate ECS service.

```text
Browser
   |
   v
ALB
   |
   +-- / -----------------> Frontend
   |
   +-- /api/auth/* -------> Auth Service
   |
   +-- /api/products* ----> Catalog Service
   |
   +-- /api/cart* --------> Order Service
   |
   +-- /api/orders* ------> Order Service
```

---

## Order Event Flow

When an order is created, the Order Service stores the order in PostgreSQL and publishes an `ORDER_CREATED` event to Amazon SQS.

```text
Order Service
      |
      +----> RDS PostgreSQL
      |
      +----> SQS
              |
              v
           Lambda
              |
              v
             SNS
```

Example event:

```json
{
  "eventId": "f7cab367-286a-40d8-92a2-347578ab115c",
  "eventType": "ORDER_CREATED",
  "eventVersion": 1,
  "occurredAt": "2026-09-26T14:12:11.008Z",
  "source": "order-service",
  "data": {
    "orderId": "4",
    "userId": "1",
    "total": 4797,
    "status": "CONFIRMED"
  }
}
```

---

## Database and Caching

### Amazon RDS PostgreSQL

RDS PostgreSQL is deployed in private subnets and is not publicly accessible.

ECS services access PostgreSQL through security-group based access.

```text
ECS
 |
 | TCP 5432
 v
RDS PostgreSQL
```

### Amazon ElastiCache Redis

Redis is used by the Catalog Service for caching frequently accessed product data.

```text
Catalog Service
      |
      v
    Redis
      |
      +---- Cache Hit
      |
      +---- Cache Miss ---> PostgreSQL
```

---

## Security

The application follows a layered network architecture.

```text
Internet
   |
   v
Public ALB
   |
   v
Private ECS Services
   |
   +----> Private RDS
   |
   +----> Private Redis
```

Security Groups control communication between the different layers.

Sensitive configuration is stored in AWS Secrets Manager.

Examples:

* Database username
* Database password
* JWT secret

Secrets are not stored directly in the application source code.

---

## IAM

Separate IAM roles are used for ECS tasks and Lambda.

The Order Service task role has permission to publish messages to the Order SQS queue.

The Lambda execution role has permissions to:

* Receive SQS messages
* Delete processed messages
* Write CloudWatch logs
* Publish messages to SNS

IAM resources are managed using Terraform.

---

## SQS and Dead Letter Queue

The Order Service uses a standard SQS queue.

A Dead Letter Queue is configured to handle messages that repeatedly fail processing.

```text
Order Service
      |
      v
     SQS
      |
      v
   Lambda
      |
   Failure
      |
    Retry
      |
   Failure
      |
    Retry
      |
   Failure
      |
      v
     DLQ
```

Maximum receive count:

```text
3
```

The DLQ is monitored using CloudWatch.

---

## Monitoring

Amazon CloudWatch is used for monitoring ECS and SQS.

### ECS Monitoring

CPU and memory alarms are configured for:

* Frontend
* Auth Service
* Catalog Service
* Order Service

### SQS DLQ Monitoring

CloudWatch monitors the number of visible messages in the DLQ.

```text
DLQ Message
     |
     v
CloudWatch Alarm
     |
     v
SNS Alerts
     |
     v
Email Notification
```

---

## ECS Autoscaling

ECS services use Application Auto Scaling with step scaling policies.

### Capacity

```text
Minimum tasks: 1
Maximum tasks: 3
```

### Scale Out

```text
CPU 60–70%   → +1 task
CPU 70–80%   → +2 tasks
CPU >=80%    → +3 tasks
```

### Scale In

```text
CPU 30–40%   → -1 task
CPU <30%     → -2 tasks
```

Scaling flow:

```text
ECS CPU Utilization
        |
        v
CloudWatch Alarm
        |
        v
Step Scaling Policy
        |
        v
ECS Desired Count
        |
        v
More/Fewer Tasks
```

---

## CI/CD

GitHub Actions is used to build Docker images and push them to Amazon ECR.

```text
Developer
    |
    v
Git Push
    |
    v
GitHub Actions
    |
    v
Docker Build
    |
    v
Amazon ECR
```

ECR repositories:

```text
shopkart/ecs-frontend
shopkart/ecs-auth-service
shopkart/ecs-catalog-service
shopkart/ecs-order-service
```

Docker images are tagged using the Git commit SHA.

---

## Infrastructure as Code

The AWS infrastructure is provisioned using modular Terraform.

```text
terraform/
├── modules/
│   ├── vpc/
│   ├── security-groups/
│   ├── iam/
│   ├── ecs/
│   ├── alb/
│   ├── rds/
│   ├── redis/
│   ├── sqs/
│   ├── lambda-order-processor/
│   ├── sns/
│   └── cloudwatch/
│
└── environments/
    └── dev/
```

Terraform commands:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

---

## Health Checks

Backend services expose health endpoints:

```text
GET /health
```

These endpoints are used by the Application Load Balancer target groups to determine service health.

---

## Failure Handling

The project includes failure-handling mechanisms such as:

* ECS health checks
* ALB target health checks
* SQS retries
* SQS Dead Letter Queue
* CloudWatch alarms
* SNS notifications
* Application-level event IDs

The Lambda/SQS failure flow has been tested by intentionally causing Lambda processing failures and verifying that messages eventually reach the DLQ.

---

## Project Structure

```text
ShopKart-AWS-Native/
│
├── services/
│   ├── frontend/
│   ├── auth-service/
│   ├── catalog-service/
│   └── order-service/
│
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── security-groups/
│   │   ├── iam/
│   │   ├── ecs/
│   │   ├── alb/
│   │   ├── rds/
│   │   ├── redis/
│   │   ├── sqs/
│   │   ├── lambda-order-processor/
│   │   ├── sns/
│   │   └── cloudwatch/
│   │
│   └── environments/
│       └── dev/
│
├── .github/
│   └── workflows/
│
└── README.md
```

---

## Technologies

### Cloud

* AWS
* ECS
* Fargate
* ALB
* RDS
* ElastiCache
* SQS
* Lambda
* SNS
* CloudWatch
* ECR
* IAM
* Secrets Manager
* VPC

### DevOps

* Terraform
* Docker
* GitHub Actions
* Git
* CI/CD
* Infrastructure as Code

### Application

* Node.js
* Express
* PostgreSQL
* Redis
* HTML/CSS/JavaScript

---

## Key Highlights

* Designed a containerized microservices architecture on AWS.
* Deployed independent services using ECS/Fargate.
* Implemented ALB path-based routing.
* Used private subnets for ECS, RDS, and Redis.
* Implemented Redis caching using ElastiCache.
* Implemented asynchronous order processing using SQS and Lambda.
* Implemented SQS retry and DLQ handling.
* Integrated SNS for event publishing and alert notifications.
* Implemented CloudWatch monitoring and alarms.
* Implemented ECS step scaling.
* Managed infrastructure using reusable Terraform modules.
* Implemented GitHub Actions CI pipeline with Amazon ECR.
* Managed application secrets using AWS Secrets Manager.
* Applied IAM role-based access control.

---

## Future Improvements

* HTTPS with ACM
* Route 53 custom domain
* Fully automated ECS deployment through GitHub Actions
* Blue/green deployment
* AWS WAF
* Production multi-AZ configuration
* Enhanced observability and distributed tracing
* Additional event-driven consumers

---

## Author

**Mahesh Maharana**

DevOps / Cloud Engineer

GitHub: [https://github.com/maheshkumar198/ShopKart-AWS-Native](https://github.com/maheshkumar198/ShopKart-AWS-Native)

```
```
