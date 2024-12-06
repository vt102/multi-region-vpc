module "spoke-vpc-us-east-2_primary" {
  source = "./modules/vpc"

  depends_on = [
    module.tgw-spoke-us-east-2
  ]

  providers = {
    aws.local = aws.us-east-2
    aws.hub   = aws.hub
  }

  region   = "us-east-2"
  name = "AC_VPC_spoke-us-east-2_pri"

  cidr            = "10.1.0.0/16"
  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.128.0/24", "10.1.129.0/24", "10.1.130.0/24"]

  tgw-id = module.tgw-spoke-us-east-2.id

  tgw-hub-rt-id     = aws_ec2_transit_gateway.tgw-hub.propagation_default_route_table_id
  tgw-attachment-id = module.tgw-spoke-us-east-2.attachment-id
}

module "spoke-vpc-us-east-2_secondary" {
  source = "./modules/vpc"

  depends_on = [
    module.tgw-spoke-us-east-2
  ]

  providers = {
    aws.local = aws.us-east-2
    aws.hub   = aws.hub
  }

  region   = "us-east-2"
  name = "AC_VPC_spoke-us-east-2_sec"

  cidr            = "10.4.0.0/16"
  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.4.1.0/24", "10.4.2.0/24", "10.4.3.0/24"]
  public_subnets  = ["10.4.128.0/24", "10.4.129.0/24", "10.4.130.0/24"]

  tgw-id = module.tgw-spoke-us-east-2.id

  tgw-hub-rt-id     = aws_ec2_transit_gateway.tgw-hub.propagation_default_route_table_id
  tgw-attachment-id = module.tgw-spoke-us-east-2.attachment-id
}

module "spoke-vpc-us-west-2_primary" {
  source = "./modules/vpc"

  depends_on = [
    module.tgw-spoke-us-west-2
  ]

  providers = {
    aws.local = aws.us-west-2
    aws.hub   = aws.hub
  }

  region   = "us-west-2"
  name = "AC_VPC_spoke-us-west-2_pri"

  cidr            = "10.2.0.0/16"
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  public_subnets  = ["10.2.128.0/24", "10.2.129.0/24", "10.2.130.0/24"]

  tgw-id = module.tgw-spoke-us-west-2.id

  tgw-hub-rt-id     = aws_ec2_transit_gateway.tgw-hub.propagation_default_route_table_id
  tgw-attachment-id = module.tgw-spoke-us-west-2.attachment-id
}

module "spoke-vpc-us-west-2_secondary" {
  source = "./modules/vpc"

  depends_on = [
    module.tgw-spoke-us-west-2
  ]

  providers = {
    aws.local = aws.us-west-2
    aws.hub   = aws.hub
  }

  region   = "us-west-2"
  name = "AC_VPC_spoke-us-west-2_sec"

  cidr            = "10.3.0.0/16"
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
  public_subnets  = ["10.3.128.0/24", "10.3.129.0/24", "10.3.130.0/24"]

  tgw-id = module.tgw-spoke-us-west-2.id

  tgw-hub-rt-id     = aws_ec2_transit_gateway.tgw-hub.propagation_default_route_table_id
  tgw-attachment-id = module.tgw-spoke-us-west-2.attachment-id
}
