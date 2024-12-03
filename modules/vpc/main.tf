provider "aws" {
  region = var.region
}

module "vpc_module" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  create_vpc = true
  name       = var.vpc_name

  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  manage_default_route_table = true

  vpc_tags = {
    Name = var.vpc_name
  }
}
