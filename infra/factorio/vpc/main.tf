resource "aws_vpc" "simple_vpc" {
  cidr_block = "10.0.0.0/22"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.simple_vpc.id
  availability_zone = var.availability_zone
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
