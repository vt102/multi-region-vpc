terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "ac-terraform-backend-terraformbackends3bucket-3wba0eny6hde"
    key            = "multi-region-vpc"
    region         = "us-east-2"
    dynamodb_table = "AC-terraform-backend-TerraformBackendDynamoDBTable-10RMAYY0RR7F1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  shared_config_files = ["~/.aws/config"]
  profile             = "eng_playground"

  default_tags {
    tags = {
      Environment = "Development"
      Owner       = "andy.cowell@rearc.io"
    }
  }
}
