##
## Transit Gateway network
##

# Hub

resource "aws_ec2_transit_gateway" "tgw-hub" {
  provider = aws.hub

  auto_accept_shared_attachments  = "enable"

  tags = {
    Name = "AC_TGW_HUB"
  }
}

# Spokes

## us-east-2

module "tgw-spoke-us-east-2" {
  source   = "./modules/tgw-spoke"

  providers = {
    aws.local = aws.us-east-2
    aws.hub   = aws.hub
  }

  region = "us-east-2"
  hub-id = aws_ec2_transit_gateway.tgw-hub.id
  hub-account-id         = aws_ec2_transit_gateway.tgw-hub.owner_id
  name = "AC_TGW_Spoke_us-east-2"
}

## us-west-2

module "tgw-spoke-us-west-2" {
  source   = "./modules/tgw-spoke"

  providers = {
    aws.local = aws.us-west-2
    aws.hub   = aws.hub
  }

  region = "us-west-2"
  hub-id = aws_ec2_transit_gateway.tgw-hub.id
  hub-account-id         = aws_ec2_transit_gateway.tgw-hub.owner_id
  name = "AC_TGW_Spoke_us-west-2"
}
