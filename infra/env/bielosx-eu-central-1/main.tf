provider "aws" {
  region = "eu-central-1"
}

module "factorio" {
  source = "../../factorio"
  region = "eu-central-1"
  factorio_version = "1.1.38"
  enable_server = false
}