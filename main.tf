#defining providers

provider "hcp" {
}


data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = var.tfc_org_name
    workspaces = {
      name = var.tfc_network_workspace_name
    }
  }
}

provider "aws" {
  region = data.terraform_remote_state.network.outputs.region
  //region = var.region
}

#defining ec2 instance using module - FE - all outputs from networking resources
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "my-ec2-instance"
  instance_type = var.instance_type
  key_name = aws_key_pair.labyrinth_kp.key_name
  ami = data.hcp_packer_image.ubuntu.cloud_image_id

  subnet_id              = data.terraform_remote_state.network.outputs.subnet_id[0]
  vpc_security_group_ids = data.terraform_remote_state.network.outputs.security_group_id

  tags = {
    Name = "MyEC2Instances"
  }

}

#fetching information about Packer image - FE
data "hcp_packer_iteration" "ubuntu" {
  bucket_name = var.hcp_bucket_ubuntu
  channel     = var.hcp_channel
}
#uses above to give image info to AWS - FE
data "hcp_packer_image" "ubuntu" {
  bucket_name    = data.hcp_packer_iteration.ubuntu.bucket_name
  iteration_id   = data.hcp_packer_iteration.ubuntu.ulid
  cloud_provider = "aws"
  region         = data.terraform_remote_state.network.outputs.region
}

#generates private key to use for key pair - FE
resource "tls_private_key" "labyrinth" {
  algorithm = "RSA"
}
#defines local var for key file name - FE
locals {
  private_key_filename = "labyrinth-key.pem"
}

#creates key pair used to access ec2 instance - FE
resource "aws_key_pair" "labyrinth_kp" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.labyrinth.public_key_openssh
}

# Defines the Elastic IP
resource "aws_eip" "labyrinth-eip" {
  domain = "vpc"

  tags = {
    Name = "MyEC2Instances"
  }
}

# Associates the Elastic IP with the EC2 instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2_instance.id
  allocation_id = aws_eip.labyrinth-eip.id
}

resource "aws_lb" "nlb" {
  name               = var.nlb_name
  internal           = var.nlb_internal
  load_balancer_type = "network"
  security_groups    = [data.aws_security_group.default.id]
  subnets            = data.aws_subnets.selected.ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

resource "aws_lb_target_group" "nlb_tg" {
  name     = "nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    interval            = 30
    protocol            = "TCP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = var.tags
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

output "nlb_arn" {
  value = aws_lb.nlb.arn
}

output "nlb_dns_name" {
  value = aws_lb.nlb.dns_name
}
