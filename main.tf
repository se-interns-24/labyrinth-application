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


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.9.0"

  name                       = var.alb_name
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
  internal                   = var.alb_internal
  security_groups            = data.terraform_remote_state.network.outputs.security_group_id
  subnets            = [data.terraform_remote_state.network.outputs.subnet_id[0], data.terraform_remote_state.network.outputs.subnet_id_b[0]]
  enable_deletion_protection = var.enable_deletion_protection
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.7.0"

  name                  = "my-autoscaling-group"
  min_size              = 0
  max_size              = 2
  desired_capacity      = 1
  health_check_type     = "EC2"
  vpc_zone_identifier   = [data.terraform_remote_state.network.outputs.subnet_id[0]]
  //instance_type = var.instance_type
  launch_template_id = aws_launch_template.my_template.id
}


resource "aws_launch_template" "my_template" {
  name          = "my-launch-template"
  //image_id       = "ami-0abcdef1234567890" # Replace with you
  instance_type = "t2.micro"
}
