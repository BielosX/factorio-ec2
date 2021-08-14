provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_ebs_volume" "saves_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size = 10
}

data "aws_ami" "factorio_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["factorio-${var.factorio_version}"]
  }
  owners = ["self"]
}

resource "aws_security_group" "factorio_sg" {
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 34197
    protocol = "udp"
    to_port = 34197
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
}

resource "aws_instance" "factorio_server" {
  ami = data.aws_ami.factorio_image.id
  instance_type = "t3.micro"
  associate_public_ip_address = true
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_security_group_ids = [aws_security_group.factorio_sg.id]
  user_data = file("${path.module}/init.sh")
  disable_api_termination = true
  instance_initiated_shutdown_behavior = "stop"
}

resource "aws_volume_attachment" "attach_ebs" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.factorio_server.id
  volume_id = aws_ebs_volume.saves_volume.id
}