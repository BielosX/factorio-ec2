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

resource "aws_vpc" "simple_vpc" {
  cidr_block = "10.0.0.0/22"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.simple_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.simple_vpc.id
}

resource "aws_route_table" "vpc_public_route_table" {
  vpc_id = aws_vpc.simple_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_table_assoc" {
  route_table_id = aws_route_table.vpc_public_route_table.id
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_security_group" "factorio_sg" {
  vpc_id = aws_vpc.simple_vpc.id
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
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    protocol = "tcp"
    to_port = 443
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
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    "Name": "factorio-server"
  }
}

resource "aws_volume_attachment" "attach_ebs" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.factorio_server.id
  volume_id = aws_ebs_volume.saves_volume.id
}