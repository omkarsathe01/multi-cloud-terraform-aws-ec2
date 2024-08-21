terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = bucket
    key    = "multi-cloud-terraform-aws-ec2"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}
