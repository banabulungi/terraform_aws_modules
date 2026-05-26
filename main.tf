module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

module "s3_bucket" {
  source = "./modules/s3_bucket"

  bucket_name  = var.bucket_name
  project_name = var.project_name
  environment  = var.environment
}
