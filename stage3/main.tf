terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }

  backend "s3" {
    bucket  = "nereydacastro-final-state-bucket-v2"
    key     = "stage3/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true 
  }
}

provider "aws" {
  region = "us-east-1"
}
