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
}

variable "nlb_name" {
  description = "The name of the NLB"
  default = "my-nlb"
}

variable "nlb_internal" {
  description = "Whether the NLB is internal"
  default     = false
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the NLB"
  default     = false
}

variable "alb_name" {
  description = "The name of the Application Load Balancer"
  type        = string
  default     = "my-alb"
}

variable "alb_internal" {
  description = "Whether the load balancer is internal or external"
  type        = bool
  default     = false
}
