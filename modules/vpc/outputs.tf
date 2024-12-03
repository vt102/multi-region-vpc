output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc_module.vpc_id
}

output "private_subnets" {
  description = "List of the private subnets' IDs"
  value       = module.vpc_module.private_subnets
}

output "public_subnets" {
  description = "List of the public subnets' IDs"
  value       = module.vpc_module.public_subnets
}
