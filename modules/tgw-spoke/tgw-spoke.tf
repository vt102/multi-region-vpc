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

variable region {
  type = string
}

variable name {
  type = string
}

variable hub-id {
  type = string
}

variable hub-account-id {
  type = string
}

resource "aws_ec2_transit_gateway" "tgw-spoke" {
  provider = aws.local

  auto_accept_shared_attachments  = "enable"

  tags = {
    Name = var.name
  }
}

# Peer TGW to Hub

resource "aws_ec2_transit_gateway_peering_attachment" "hub-to-tgw-spoke" {
  provider = aws.local

  transit_gateway_id = aws_ec2_transit_gateway.tgw-spoke.id

  peer_transit_gateway_id = var.hub-id
  peer_account_id         = var.hub-account-id
  peer_region             = "us-east-1"
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "hub-to-tgw-spoke_accepter" {
  provider = aws.hub

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.hub-to-tgw-spoke.id
}

# Route to the rest of our internal network

resource "aws_ec2_transit_gateway_route" "internal_to_hub" {
  provider = aws.local

  # Need to wait on the peering to be complete
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.hub-to-tgw-spoke_accepter
  ]

  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw-spoke.propagation_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.hub-to-tgw-spoke.id
}

output "id" {
  value = aws_ec2_transit_gateway.tgw-spoke.id
}

output "attachment-id" {
  value = aws_ec2_transit_gateway_peering_attachment.hub-to-tgw-spoke.id
}
