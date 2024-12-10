output "ec21-ext-ip" {
  value = module.ec21.public_ip
}

output "ec22-ext-ip" {
  value = module.ec22.public_ip
}

output "ec23-ext-ip" {
  value = module.ec23.public_ip
}

output "ec21-int-ip" {
  value = module.ec21.private_ip
}

output "ec22-int-ip" {
  value = module.ec22.private_ip
}

output "ec23-int-ip" {
  value = module.ec23.private_ip
}

output "tgw-hub-id" {
  value = aws_ec2_transit_gateway.tgw-hub.id
}

output "tgw-spoke-us-east-2-id" {
#  value = aws_ec2_transit_gateway.spoke-us-east-2.id
  value = module.tgw-spoke-us-east-2.id
}
