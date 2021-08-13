provider "aws" {
  region = "eu-west-1"
}

module "factorio" {
  source = "../../factorio"
  region = "eu-west-1"
}