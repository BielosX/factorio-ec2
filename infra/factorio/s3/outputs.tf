output "saves_backup_bucket_id" {
  value = aws_s3_bucket.saves_backup_bucket.id
}

output "config_bucket_id" {
  value = aws_s3_bucket.config_bucket.id
}