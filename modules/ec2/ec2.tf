provider "aws" {
  region = var.region
}

##
## Instance Profile
##

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
#  name       = "ssm-policy-attach"
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}-instance_profile"
  role = aws_iam_role.ec2_ssm_role.name
}

##
## Security group
##

resource "aws_security_group" "ac_security_group" {
  name        = "AndyC_SG"
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
  ip_protocol       = "-1" # semantically equivalent to all ports
}

##
##

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "AC-test-01"

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
