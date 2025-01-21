# Call modules for resources
module "vpc" {
  source  = "./modules/vpc"
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets
}

module "rds" {
  source              = "./modules/rds"
  major_engine_version = var.major_engine_version
  family              = var.family
  subnet_ids          = module.vpc.private_subnets
}

module "alb" {
  source = "./modules/alb"
}

module "iam" {
  source = "./modules/iam"
}

