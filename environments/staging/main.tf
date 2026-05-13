provider "aws" {
  region = "us-east-1" # Change this to your preferred region
}

module "networking" {
  source           = "../../modules/networking"
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
}

module "web-cluster" {
  source                = "../../modules/web-cluster"
  environment           = var.environment
  vpc_id                = module.networking.vpc_id # value comes from networking module output
  alb_subnet_ids        = module.networking.public_subnet_ids
  instance_subnet_ids   = module.networking.private_subnet_ids
  scaling_config        = var.scaling_config
  instance_type         = var.instance_type
}











