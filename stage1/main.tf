terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "nereydacastro-final-state-bucket-v2"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
resource "aws_ecr_repository" "django_app" {
  name                 = "django_image"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

import {
  to = aws_ecr_repository.django_app
  id = "django_image"
}
