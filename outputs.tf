/*
output "public_dns_name" {
  value = data.terraform_remote_state.network.outputs.public_dns_name
}
*/

#outputs app url
output "app_url" {
  value = "http://${module.ec2_instance.public_ip}"
}
/*
output "instance-id" {
  value = aws_instance.this.id
}*/
