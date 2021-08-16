data "amazon-ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true
  region = var.region
  filters = {
    virtualization-type = "hvm"
    name = "amzn2-ami-hvm-*-x86_64-gp2"
    root-device-type = "ebs"
  }
}

source "amazon-ebs" "main" {
  ami_name = "factorio-${var.factorio_version}"
  region = var.region
  profile = "default"
  instance_type = "t3.medium"
  ssh_username = "ec2-user"
  source_ami = data.amazon-ami.amazon-linux-2.id
}

build {
  sources = ["source.amazon-ebs.main"]
  provisioner "shell" {
    script = "install_tools.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }} ${var.region}'"
  }
  provisioner "file" {
    source = "../factorio.service"
    destination = "/tmp/factorio.service"
  }
  provisioner "file" {
    source = "../settings-loader.service"
    destination = "/tmp/settings-loader.service"
  }
  provisioner "file" {
    source = "../factorio_run.sh"
    destination = "/tmp/factorio_run.sh"
  }
  provisioner "file" {
    source = "../load_settings.sh"
    destination = "/tmp/load_settings.sh"
  }
  provisioner "shell" {
    script = "../install_extras.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }
  provisioner "shell" {
    script = "../copy_to_priv.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }
  provisioner "shell" {
    script = "../factorio_install.sh"
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }} ${var.factorio_version}'"
  }
}