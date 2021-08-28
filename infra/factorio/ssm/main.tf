resource "aws_ssm_document" "saves_backup" {
  name = "factorio_saves_backup"
  document_type = "Command"
  content = templatefile("${path.module}/backup_saves_document.yaml.tmpl", {
    "bucket_name": var.saves_backup_bucket_id
  })
  document_format = "YAML"
}
