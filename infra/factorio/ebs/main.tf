resource "aws_ebs_volume" "saves_volume" {
  availability_zone = var.availability_zone
  size = 5
  type = "gp3"
  iops = 3000
  throughput = 125
  lifecycle {
    prevent_destroy = true
  }
}
