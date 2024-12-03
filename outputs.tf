output "ec21-ext-ip" {
  value = module.ec21.public_ip
}

output "ec22-ext-ip" {
  value = module.ec22.public_ip
}

output "ec21-int-ip" {
  value = module.ec21.private_ip
}

output "ec22-int-ip" {
  value = module.ec22.private_ip
}
