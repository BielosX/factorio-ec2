data "amazon-ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true
  region = "eu-central-1"
  filters = {
    virtualization-type = "hvm"
    name = "amzn2-ami-hvm-*-x86_64-gp2"
    root-device-type = "ebs"
  }
}

source "amazon-ebs" "main" {
  ami_name = "factorio-${var.factorio_version}"
  region = "eu-central-1"
  profile = "default"
  instance_type = "t3.medium"
  ssh_username = "ec2-user"
  source_ami = data.amazon-ami.amazon-linux-2.id
}

build {
  sources = ["source.amazon-ebs.main"]
  provisioner "shell" {
    inline = ["echo Connected via SSM at '${build.User}@${build.Host}:${build.Port}'"]
  }
}