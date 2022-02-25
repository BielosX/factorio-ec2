locals {
  server_settings = "${path.module}/../../../server_config/server-settings.json"
  server_admin_list = "${path.module}/../../../server_config/server-adminlist.json"
  map_gen_settings = "${path.module}/../../../server_config/map-gen-settings.json"
  map_settings = "${path.module}/../../../server_config/map-settings.json"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "factorio-config-bucket-${data.aws_caller_identity.current.account_id}-${var.region}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "config_bucket_acl" {
  bucket = aws_s3_bucket.config_bucket.id
  acl = "public-read"
}

resource "aws_s3_bucket" "saves_backup_bucket" {
  bucket = "factorio-saves-buckup-${data.aws_caller_identity.current.account_id}-${var.region}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "saves_backup_bucket_versioning" {
  bucket = aws_s3_bucket.saves_backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "saves_backup_bucket_acl" {
  bucket = aws_s3_bucket.saves_backup_bucket.id
  acl = "public-read"
}

resource "aws_s3_bucket_object" "server_settings" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "server-settings.json"
  source = local.server_settings
  source_hash = filemd5(local.server_settings)
}

resource "aws_s3_bucket_object" "server_admin_list" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "server-adminlist.json"
  source = local.server_admin_list
  source_hash = filemd5(local.server_admin_list)
}

resource "aws_s3_bucket_object" "map-gen-settings" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "map-gen-settings.json"
  source = local.map_gen_settings
  source_hash = filemd5(local.map_gen_settings)
}

resource "aws_s3_bucket_object" "map-settings" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "map-settings.json"
  source = local.map_settings
  source_hash = filemd5(local.map_settings)
}
