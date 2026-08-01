terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" #change from 6 to 5, a potential vrns issue
    }
  }

  backend "s3" {
    bucket = "nereydacastro-final-state-bucket-v2"
    key    = "stage1/terraform.tfstate"
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
