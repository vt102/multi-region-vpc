variable "region" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = "default_vpc_name"
}

variable "azs" {
  type = list(string)
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.128.0/24", "10.0.129.0/24", "10.0.130.0/24"]
}
