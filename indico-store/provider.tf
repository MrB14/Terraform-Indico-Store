# Define Terraform provider
provider "aws" {
  region  = var.aws_region
  version = "~> 5.0"
}

terraform {
  backend "remote" {
    organization = "indico-store"

    workspaces {
      name = "indico-store-production"
    }
  }
}
