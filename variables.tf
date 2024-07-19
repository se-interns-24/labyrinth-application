variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
variable "hcp_bucket_ubuntu" {
  description = "The Bucket where our AMI is listed."
  default     = "labyrinth"
}

variable "hcp_channel" {
  description = "HCP Packer channel name"
  default     = "labyrinth-channel"
}

variable "tfc_org_name" {
  description = "Name of the Terraform Cloud Organization"
  type        = string
  default     = "se-intern-project"
}

variable "tfc_network_workspace_name" {
  description = "Name of the network workspace"
  type        = string
  default     = "labyrinth-network-dev"
}

variable "tfc_network_dev_workspace" {
  description = "Name of the network dev workspace"
  type        = string
  default     = "labyrinth-network-dev"
}

variable "tfc_network_stage_workspace" {
  description = "Name of the network stage workspace"
  type        = string
  default     = "labyrinth-network-stage"
}

variable "tfc_network_prod_workspace" {
  description = "Name of the network prod workspace"
  type        = string
  default     = "labyrinth-network-prod"
}
