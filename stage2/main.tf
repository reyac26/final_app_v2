variable "DJANGO_SECRET_KEY_PROD" {
  type      = string
  sensitive = true
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }

  backend "s3" {
    bucket = "nereydacastro-final-state-bucket-v2"
    key    = "stage2/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ecr_repository" "django_app" {
  name = "django_image"
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "django-ecs-security-group-nereyda"
  description = "Allow inbound traffic to Django application container"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "django-production-cluster"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-task-execution-role-nereyda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" } 
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "django_task" {
  family                   = "django-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name         = "django-container"
    image        = "${data.aws_ecr_repository.django_app.repository_url}:latest"
    essential    = true
portMappings = [{ containerPort = 8000, hostPort = 8000 }]    
environment  = [{ name = "DJANGO_SECRET_KEY", value = var.DJANGO_SECRET_KEY_PROD }]
  }])
}

resource "aws_ecs_service" "django_service" {
  name            = "django-fargate-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.django_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
