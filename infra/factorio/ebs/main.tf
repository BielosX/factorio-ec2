resource "aws_ebs_volume" "saves_volume" {
  count = var.enable_server ? 1 : 0
  availability_zone = var.availability_zone
  size = 5
  type = "gp3"
  iops = 3000
  throughput = 125
}
