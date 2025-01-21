# Terraform configuration for Indico Store's EKS-based
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

# Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-3"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "indico-store-eks"
}

variable "major_engine_version" {
  description = "Major version of the database engine"
  type        = string
  default     = "8.0"
}

variable "family" {
  description = "Family of the DB parameter group"
  type        = string
  default     = "mysql8.0"
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 3
      max_capacity     = 6
      min_capacity     = 2
      instance_types   = ["t3.medium"]
    }
  }
  subnet_ids = module.vpc.public_subnets
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "indico-store-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["ap-southeast-3a", "ap-southeast-3b", "ap-southeast-3c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# IAM Role for EKS
module "iam" {
  source  = "terraform-aws-modules/iam/aws"
}

# S3 Bucket for Static Files
resource "aws_s3_bucket" "static_files" {
  bucket = "indico-store-static-files-${random_string.suffix.result}"
  acl    = "public-read"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# RDS for Database
module "rds" {
  source              = "terraform-aws-modules/rds/aws"
  engine              = "mysql"
  engine_version      = "8.0"
  major_engine_version = var.major_engine_version
  instance_class      = "db.t3.medium"
  allocated_storage   = 20
  identifier          = "indicostore"
  username            = "admin"
  password            = "password123"
  publicly_accessible = false
  family              = var.family
  subnet_ids          = module.vpc.private_subnets
}

# Load Balancer
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "indico-store-alb"
  internal           = false
  security_groups    = [module.vpc.default_security_group_id]
  subnets            = module.vpc.public_subnets
  enable_http2       = true
  enable_deletion_protection = false
}

# Outputs
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.static_files.bucket
}
