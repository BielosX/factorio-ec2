data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "saves_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size = 5
  type = "gp3"
  iops = 3000
  throughput = 125
  lifecycle {
    prevent_destroy = true
  }
}
