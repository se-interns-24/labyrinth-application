packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  default = "us-east-2"
}

source "amazon-ebs" "game" {
  region       = var.region
  communicator = "ssh"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type = "t2.micro"
  ami_name      = "packer-game-example {{timestamp}}"
  ssh_username  = "ubuntu"
}

build {

  hcp_packer_registry {
    bucket_name = "labyrinth"
    description = "labyrinth game"
    #bucket_labels = var.aws_tags
    build_labels = {
      "build-time"   = timestamp(),
      "build-source" = basename(path.cwd)
    }
  }

  sources = ["source.amazon-ebs.game"]

  provisioner "file" {
    source      = "install_game.sh"
    destination = "/tmp/install_game.sh"
  }

  provisioner "shell" {
    inline = ["chmod +x /tmp/install_game.sh"]
  }

  provisioner "shell" {
    inline = ["/tmp/install_game.sh"]
  }
}




