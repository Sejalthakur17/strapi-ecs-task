terraform {
  backend "s3" {
    bucket  = "sejal-strapi-fargate-task7"
    key     = "sejal-fargate/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}
