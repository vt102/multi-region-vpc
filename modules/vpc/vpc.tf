##
## Backend
##

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [
	aws.local, aws.hub
      ]
    }
  }
}

##
## Variables
##

variable region {
  type = string
}

variable name {
  type = string
}

variable tgw-id {
  type = string
}

variable tgw-hub-rt-id {
  type = string
}

variable tgw-attachment-id {
  type = string
}

variable cidr {
  type = string
}

variable azs {
  type = list
}

variable private_subnets {
  type = list
}

variable public_subnets {
  type = list
}

##
## Resources
##

module "vpc_module" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  providers = {
    aws = aws.local
  }

  create_vpc = true
  name       = var.name

  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  manage_default_route_table = true

  vpc_tags = {
    Name = var.name
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-vpc-attachment" {
  provider = aws.local

  transit_gateway_id = var.tgw-id
  vpc_id             = module.vpc_module.vpc_id
  subnet_ids         = module.vpc_module.public_subnets
}

##
## NB: This assumes all private subnets share one route table, and
##     all public subnets share one route table.
##

##
## Add our "Internal default" 10.0.0.0/8 to both our public and private
## routing tables, pointing at the TGW we just attached to
##

resource "aws_route" "spoke-vpc_pub" {
  depends_on = [
    module.vpc_module,
    aws_ec2_transit_gateway_vpc_attachment.tgw-vpc-attachment
  ]
  provider = aws.local

  route_table_id         = module.vpc_module.public_route_table_ids[0]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tgw-id
}

resource "aws_route" "spoke-vpc_pri" {
  depends_on = [
    module.vpc_module,
    aws_ec2_transit_gateway_vpc_attachment.tgw-vpc-attachment
  ]
  provider = aws.local

  route_table_id         = module.vpc_module.private_route_table_ids[0]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tgw-id
}

##
## Add our VPC CIDR route to the hub TGW
##

resource "aws_ec2_transit_gateway_route" "hub-to-spoke" {
  provider = aws.hub

  destination_cidr_block         = var.cidr
  transit_gateway_route_table_id = var.tgw-hub-rt-id
  transit_gateway_attachment_id  = var.tgw-attachment-id
}

##
## Outputs
##

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
