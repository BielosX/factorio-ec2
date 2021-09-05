output "saves_volume_id" {
  value = var.enable_server ? aws_ebs_volume.saves_volume[0].id : null
}