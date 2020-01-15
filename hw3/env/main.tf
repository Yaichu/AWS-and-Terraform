provider "aws" {
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  region     = var.region
}

data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source             = "./modules/vpc"
  # name               = "vpc-1"
  # azs                = var.availability_zones
  # public_subnets     = var.subnets_cidr_public
  # private_subnets    = var.subnets_cidr_private

}
