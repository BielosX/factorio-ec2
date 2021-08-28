
data "aws_ami" "factorio_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["factorio-${var.factorio_version}-build-*"]
  }
  owners = ["self"]
}

resource "aws_security_group" "factorio_sg" {
  vpc_id = var.vpc_id
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

locals {
  dev_name = "/dev/sdf"
}

resource "aws_iam_instance_profile" "factorio_server_profile" {
  role = var.role_id
}

resource "aws_instance" "factorio_server" {
  ami = data.aws_ami.factorio_image.id
  instance_type = "t3.medium"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.factorio_sg.id]
  iam_instance_profile = aws_iam_instance_profile.factorio_server_profile.id
  user_data = templatefile("${path.module}/init.sh.tmpl",
  {
    "cw_config_param": aws_ssm_parameter.cw_config_param.id
    "dev_name": local.dev_name
    "config_bucket": var.config_bucket_id
  })
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"
  subnet_id = var.subnet_id

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
  volume_id = var.saves_volume_id
}
