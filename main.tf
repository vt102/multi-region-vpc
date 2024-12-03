provider "aws" {
  alias  = "east1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Development"
      Owner       = "andy.cowell@rearc.io"
    }
  }
}

provider "aws" {
  alias  = "east2"
  region = "us-east-2"

  default_tags {
    tags = {
      Environment = "Development"
      Owner       = "andy.cowell@rearc.io"
    }
  }
}

module "vpc1" {
  source = "./modules/vpc"
  region = "us-east-1"

  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name = "${var.vpc_name}-us-east-1"

  cidr            = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.128.0/24", "10.0.129.0/24", "10.0.130.0/24"]
}

module "vpc2" {
  source = "./modules/vpc"
  region = "us-east-2"

  azs      = ["us-east-2a", "us-east-2b", "us-east-2c"]
  vpc_name = "${var.vpc_name}-us-east-2"

  cidr            = "10.1.0.0/16"
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.128.0/24", "10.1.129.0/24", "10.1.130.0/24"]
}

# module "tgw1" {
#   source = "terraform-aws-modules/transit-gateway/aws"
#   version = "~> 2.0"

#   name        = "AndyC-tgw"

#   enable_auto_accept_shared_attachments = true

#   vpc_attachments = {
#     vpc1 = {
#       vpc_id     = module.vpc1.vpc_id
#       subnet_ids = concat(module.vpc1.private_subnets, module.vpc1.public_subnets)
#       dns_support = true

#       transit_gateway_default_route_table_association = false
#       transit_gateway_default_route_table_propogation = false
#     }
#   }
# }

resource "aws_ec2_transit_gateway" "tgw1" {
  provider = aws.east1

#  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"

  tags = {
    Name = "AC_TGW_1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw1-vpc1" {
  provider = aws.east1
  transit_gateway_id = aws_ec2_transit_gateway.tgw1.id
  vpc_id             = module.vpc1.vpc_id
  subnet_ids         = module.vpc1.public_subnets
}

resource "aws_ec2_transit_gateway" "tgw2" {
  provider = aws.east2

#  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"

  tags = {
    Name = "AC_TGW_2"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw2-vpc2" {
  provider = aws.east2
  transit_gateway_id = aws_ec2_transit_gateway.tgw2.id
  vpc_id             = module.vpc2.vpc_id
  subnet_ids         = module.vpc2.public_subnets
}

resource "aws_ec2_transit_gateway_peering_attachment" "tgw1-tgw2-peering" {
  provider = aws.east1
  transit_gateway_id = aws_ec2_transit_gateway.tgw1.id

  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw2.id
  peer_region             = "us-east-2"
  peer_account_id         = aws_ec2_transit_gateway.tgw2.owner_id
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw1-tgw2-peering_accepter" {
  provider = aws.east2

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw1-tgw2-peering.id
}

resource "aws_ec2_transit_gateway_route" "tgw1_to_10" {
  provider = aws.east1

  # Need to wait on the peering to be complete
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw1-tgw2-peering_accepter]

  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw1.propagation_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw1-tgw2-peering.id
}

resource "aws_ec2_transit_gateway_route" "tgw2_to_10" {
  provider = aws.east2

  # Need to wait on the peering to be complete
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw1-tgw2-peering_accepter]

  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw2.propagation_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw1-tgw2-peering.id
}

data "aws_route_tables" "vpc1_pub_rts" {
  provider = aws.east1
  vpc_id   = module.vpc1.vpc_id

  filter {
    name   = "tag:Name"
    values = ["andy_cowell_VPC-us-east-1-public*"]
  }
}

resource "aws_route" "vpc1_pub" {
  provider = aws.east1
#  count    = "${length(data.aws_route_tables.vpc1_pub_rts.ids)}"
  count    = 3

  route_table_id         = "${element(data.aws_route_tables.vpc1_pub_rts.ids, count.index)}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw1.id
}

data "aws_route_tables" "vpc1_pri_rts" {
  provider = aws.east1
  vpc_id   = module.vpc1.vpc_id

  filter {
    name   = "tag:Name"
    values = ["andy_cowell_VPC-us-east-1-private*"]
  }
}

resource "aws_route" "vpc1_pri" {
  provider = aws.east1
#   count    = "${length(data.aws_route_tables.vpc1_pri_rts.ids)}"
  count    = 3

  depends_on = [module.vpc1]

  route_table_id         = "${element(data.aws_route_tables.vpc1_pri_rts.ids, count.index)}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw1.id
}

data "aws_route_tables" "vpc2_pub_rts" {
  provider = aws.east2
  vpc_id   = module.vpc2.vpc_id

  filter {
    name   = "tag:Name"
    values = ["andy_cowell_VPC-us-east-2-public*"]
  }
}

resource "aws_route" "vpc2_pub" {
  provider = aws.east2
#  count    = "${length(data.aws_route_tables.vpc2_pub_rts.ids)}"
  count    = 3

  depends_on = [module.vpc2]

  route_table_id         = "${element(data.aws_route_tables.vpc2_pub_rts.ids, count.index)}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw2.id
}

data "aws_route_tables" "vpc2_pri_rts" {
  provider = aws.east2
  vpc_id   = module.vpc2.vpc_id

  filter {
    name   = "tag:Name"
    values = ["andy_cowell_VPC-us-east-2-private*"]
  }
}

resource "aws_route" "vpc2_pri" {
  provider = aws.east2
  count    = 3

  depends_on = [module.vpc2]

  route_table_id         = "${element(data.aws_route_tables.vpc2_pri_rts.ids, count.index)}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw2.id
}

# module "tgw2" {
#   source = "terraform-aws-modules/transit-gateway/aws"
#   version = "~> 2.0"

#   name        = "AndyC-tgw"

#   enable_auto_accept_shared_attachments = true

#   vpc_attachments = {
#     vpc2 = {
#       vpc_id     = module.vpc2.vpc_id
#       subnet_ids = concat(module.vpc2.private_subnets, module.vpc2.public_subnets)
#       dns_support = true

#       transit_gateway_default_route_table_association = false
#       transit_gateway_default_route_table_propogation = false
#     }
#   }
# }

module "ec21" {
  source = "./modules/ec2"

  region    = "us-east-1"
  vpc_id    = module.vpc1.vpc_id
  subnet_id = module.vpc1.public_subnets[0]
  name      = "AC-EC2-1"
}

module "ec22" {
  source = "./modules/ec2"

  region    = "us-east-2"
  vpc_id    = module.vpc2.vpc_id
  subnet_id = module.vpc2.public_subnets[0]
  name      = "AC-EC2-2"
}
