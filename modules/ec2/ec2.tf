terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.6.3"
    }
  }
}

##
## Variables
##

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ami" {
  type = map(any)
  default = {
    "us-east-1": "ami-0c614dee691cbbf37",
    "us-east-2": "ami-018875e7376831abe",
    "us-west-2": "ami-0a897ba00eaed7398"
  }

}

##
## Data
##

data "aws_region" "current" {}

##
## Resources
##

# Instance Profile

resource "aws_iam_role" "ec2_ssm_role" {
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF

}

resource "aws_iam_role_policy_attachment" "ssm-policy-attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "random_string" "uniq" {
  length  = 8
  special = false
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}-instance_profile-${random_string.uniq.result}"
  role = aws_iam_role.ec2_ssm_role.name
}

# Security group

resource "aws_security_group" "ac_security_group" {
  name        = "AndyC_SG-${random_string.uniq.result}"
  description = "Ephemeral SG for Andy Cowell"
  vpc_id      = var.vpc_id

  tags = {
    Name = "AndyC_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.ac_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ac_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# EC2 Instance

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "AC-test-01"

  ami = var.ami[data.aws_region.current.name]

  instance_type = "t2.micro"
  key_name      = "ac-delicate-glade"
  monitoring    = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids      = [aws_security_group.ac_security_group.id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

##
## Outputs
##

output "public_ip" {
  description = "The public IP of the created EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "private_ip" {
  description = "The public IP of the created EC2 instance"
  value       = module.ec2_instance.private_ip
}
