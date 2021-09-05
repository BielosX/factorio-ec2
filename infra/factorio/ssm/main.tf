resource "aws_ssm_document" "saves_backup" {
  name = "factorio_saves_backup"
  document_type = "Command"
  content = templatefile("${path.module}/backup_saves_document.yaml.tmpl", {
    "bucket_name": var.saves_backup_bucket_id
  })
  document_format = "YAML"
}


resource "aws_ssm_document" "saves_restore" {
  name = "factorio_saves_restore"
  document_type = "Command"
  content = templatefile("${path.module}/restore_saves_from_s3.yaml.tmpl", {
    "bucket_name": var.saves_backup_bucket_id
  })
  document_format = "YAML"
}