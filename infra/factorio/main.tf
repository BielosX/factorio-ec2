provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "old-ami-cleaner" {
  source = "./old-ami-cleaner"
}

locals {
  first_az = data.aws_availability_zones.available.names[0]
}

module "ebs" {
  source = "./ebs"
  availability_zone = local.first_az
}

module "vpc" {
  source = "./vpc"
  availability_zone = local.first_az
}

module "role" {
  source = "./role"
}

module "s3" {
  source = "./s3"
  region = var.region
}

module "ssm" {
  source = "./ssm"
  saves_backup_bucket_id = module.s3.saves_backup_bucket_id
}

module "ec2" {
  source = "./ec2"
  config_bucket_id = module.s3.config_bucket_id
  factorio_version = var.factorio_version
  role_id = module.role.role_id
  saves_volume_id = module.ebs.saves_volume_id
  subnet_id = module.vpc.public_subnet_id
  vpc_id = module.vpc.vpc_id
}