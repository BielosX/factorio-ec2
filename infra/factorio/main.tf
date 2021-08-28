provider "aws" {
  region = var.region
}

module "old-ami-cleaner" {
  source = "./old-ami-cleaner"
}

module "ebs" {
  source = "./ebs"
}

module "vpc" {
  source = "./vpc"
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