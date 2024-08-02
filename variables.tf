variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
variable "instance_name" {
  description = "EC2 instance name"
  default     = "my-ec2-instance"
}
variable "hcp_bucket_ubuntu" {
  description = "The Bucket where our AMI is listed."
  default     = "labyrinth"
}
variable "cloud_provider" {
  description = "Cloud provider"
  default     = "aws"
}
variable "hcp_channel" {
  description = "HCP Packer channel name"
  default     = "labyrinth-channel"
}
variable "algorithm" {
  description = "Private key algorithm"
  default     = "RSA"
}
variable "tfc_org_name" {
  description = "Name of the Terraform Cloud Organization"
  type        = string
  default     = "se-intern-project"
}
variable "private_key_filename" {
  description = "Key pair name"
  default     = "labyrinth-key.pem"
}
variable "domain" {
  description = "EIP domain"
  default     = "vpc"
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
variable "asg_name" {
  description = "Austoscaling name"
  default     = "my-autoscaling-group"
}
variable "health_check_type" {
  description = "ASG health check type"
  default     = "EC2"
}
variable "min_size" {
  description = "ASG minimum"
  default     = 0
}
variable "max_size" {
  description = "ASG maximum"
  default     = 2
}
variable "desired_capacity" {
  description = "ASG desired capacity"
  default     = 1
}
