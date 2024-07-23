/*
output "public_dns_name" {
  value = data.terraform_remote_state.network.outputs.public_dns_name
}
*/

#outputs app url
output "app_url" {
  value = "http://${module.ec2_instance.public_ip}"
}

output "db_instance_endpoint" { 
value = aws_db_instance.labyrinth-db.endpoint 
} 

output "db_instance_port" { 
value = aws_db_instance.labyrinth-db.port 
} 

output "db_instance_name" { 
value = aws_db_instance.labyrinth-db.db_name 
} 

output "db_instance_username" { 
value = aws_db_instance.labyrinth-db.username 
}








