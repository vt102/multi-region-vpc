# variable "vpc_name" {
#   description = "The name of the VPC"
#   type        = string
#   default     = "andy_cowell_VPC"
# }

# variable "regions" {
#   description = "The regions to build VPCs in"
#   type = list(object({
#     region = string
#     azs    = list(string)
#   }))
#   default = [
#     {
#       region = "us-east-1"
#       azs    = ["us-east-1a", "us-east-1b", "us-east-1c"]
#     },
#     {
#       region = "us-east-2"
#       azs    = ["us-east-2a", "us-east-2b", "us-east-2c"]
#     }
#   ]
# }
