provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "factorio-terraform-state-eu-central-1-798791225651"
    key = "terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "factorio-terraform-lock"
  }
}

module "factorio" {
  source = "../../factorio"
  region = "eu-central-1"
  factorio_version = var.factorio_version
  enable_server = true
}