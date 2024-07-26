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

  associate_public_ip_address = true

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
/*
resource "aws_db_instance" "labyrinth-db" {
  allocated_storage                     = 20
  db_subnet_group_name                  = data.terraform_remote_state.network.outputs.subnet_group_name
  engine                                = "mysql"
  engine_version                        = "8.0.35"
  identifier                            = "labyrinth-db"
  instance_class                        = "db.m6gd.large"
  parameter_group_name                  = "default.mysql8.0"
  password                              = "HashicorpInterns2024"
  publicly_accessible                   = false
  skip_final_snapshot                   = true
  username                              = "admin"
  vpc_security_group_ids                = data.terraform_remote_state.network.outputs.rds_security_group_id

  tags = {
    Name = "Labyrinth Database"
  }
}*/
