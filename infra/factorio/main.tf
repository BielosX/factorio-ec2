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

resource "aws_ssm_parameter" "cw_config_param" {
  name = "factorio_cw_config"
  type = "String"
  value = file("${path.module}/amazon-cloudwatch-agent.json")
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "factorio_server_role" {
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "factorio_server_profile" {
  role = aws_iam_role.factorio_server_role.id
}

resource "aws_iam_role_policy_attachment" "attach_cw_access" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.factorio_server_role.id
}

resource "aws_iam_role_policy_attachment" "attach_ssm_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  role = aws_iam_role.factorio_server_role.id
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role = aws_iam_role.factorio_server_role.id
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role = aws_iam_role.factorio_server_role.id
}

locals {
  dev_name = "/dev/sdf"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "factorio-config-bucket-${var.region}-${data.aws_caller_identity.current.account_id}"
  acl = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket" "saves_backup_bucket" {
  bucket = "factorio-saves-buckup-${var.region}-${data.aws_caller_identity.current.account_id}"
  acl = "public-read"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "aws_ssm_document" "saves_backup" {
  name = "factorio_saves_backup"
  document_type = "Command"
  content = templatefile("${path.module}/backup_saves_document.yaml.tmpl", {
    "bucket_name": aws_s3_bucket.saves_backup_bucket.id
  })
  document_format = "YAML"
}

resource "aws_s3_bucket_object" "server_settings" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "server-settings.json"
  source = "${path.module}/../../server-settings.json"
  source_hash = filemd5("${path.module}/../../server-settings.json")
}

resource "aws_s3_bucket_object" "server_admin_list" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "server-adminlist.json"
  source = "${path.module}/../../server-adminlist.json"
  source_hash = filemd5("${path.module}/../../server-adminlist.json")
}

resource "aws_s3_bucket_object" "map-gen-settings" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "map-gen-settings.json"
  source = "${path.module}/../../map-gen-settings.json"
  source_hash = filemd5("${path.module}/../../map-gen-settings.json")
}

resource "aws_s3_bucket_object" "map-settings" {
  bucket = aws_s3_bucket.config_bucket.id
  key = "map-settings.json"
  source = "${path.module}/../../map-settings.json"
  source_hash = filemd5("${path.module}/../../map-settings.json")
}

resource "aws_instance" "factorio_server" {
  ami = data.aws_ami.factorio_image.id
  instance_type = "t3.medium"
  associate_public_ip_address = true
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_security_group_ids = [aws_security_group.factorio_sg.id]
  iam_instance_profile = aws_iam_instance_profile.factorio_server_profile.id
  user_data = templatefile("${path.module}/init.sh.tmpl",
  {
    "cw_config_param": aws_ssm_parameter.cw_config_param.id
    "dev_name": local.dev_name
    "config_bucket": aws_s3_bucket.config_bucket.id
  })
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    "Name": "factorio-server"
  }

  credit_specification {
    cpu_credits = "standard"
  }
}

resource "aws_volume_attachment" "attach_ebs" {
  device_name = local.dev_name
  instance_id = aws_instance.factorio_server.id
  volume_id = aws_ebs_volume.saves_volume.id
}