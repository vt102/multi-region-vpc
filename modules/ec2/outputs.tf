output "public_ip" {
  description = "The public IP of the created EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "private_ip" {
  description = "The public IP of the created EC2 instance"
  value       = module.ec2_instance.private_ip
}
