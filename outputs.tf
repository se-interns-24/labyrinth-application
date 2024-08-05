#outputs app url
output "app_url" {
  value = "http://${module.ec2_instance.public_ip}"
}
