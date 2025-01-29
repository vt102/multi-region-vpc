module "ec21" {
  source = "./modules/ec2"

  providers = {
    aws = aws.us-east-2
  }

  vpc_id    = module.spoke-vpc-us-east-2_primary.vpc_id
  subnet_id = module.spoke-vpc-us-east-2_primary.public_subnets[0]
  name      = "AC-EC2-1"
}

# module "ec22" {
#   source = "./modules/ec2"

#   providers = {
#     aws = aws.us-west-2
#   }

#   vpc_id    = module.spoke-vpc-us-west-2_secondary.vpc_id
#   subnet_id = module.spoke-vpc-us-west-2_secondary.public_subnets[0]
#   name      = "AC-EC2-2"
# }

# module "ec23" {
#   source = "./modules/ec2"

#   providers = {
#     aws = aws.us-west-2
#   }

#   vpc_id    = module.spoke-vpc-us-west-2_secondary.vpc_id
#   subnet_id = module.spoke-vpc-us-west-2_secondary.public_subnets[0]
#   name      = "AC-EC2-3"
# }
