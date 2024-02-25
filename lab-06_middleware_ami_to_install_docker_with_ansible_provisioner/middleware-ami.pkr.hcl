packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

data "amazon-ami" "golden-ami" {
  filters = {
    virtualization-type = "hvm"
    name                = "golden-ami-*"
    root-device-type    = "ebs"
  }
  owners      = ["your aws id"]
  most_recent = true
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "middleware-ami" {
  ami_name      = "middleware-ami-${local.timestamp}"
  instance_type = "t2.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.golden-ami.id
  ssh_username  = "ubuntu"
  run_tags = {
    Name = "packer-vm"
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    project = "packer"
  }
}

build {
  sources = ["source.amazon-ebs.middleware-ami"]
  provisioner "ansible" {
    playbook_file    = "install_docker.yml"
    user             = "ubuntu"
    galaxy_file      = "requirements.yml"
    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'", "ANSIBLE_NOCOLOR=True"]
  }
}