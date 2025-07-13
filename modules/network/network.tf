variable "vpc_cidr" {}
variable "public_cidrs" {}
variable "private_app_cidrs" {}
variable "private_db_cidrs" {}
variable "azs" {}

variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# Network全般設定
# --------------------------------

module "vpc" {
  source = "./vpc"

  cidr = var.vpc_cidr

  name              = "${var.name}-vpc"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "public_subnet" {
  source = "./public_subnet"

  vpc_id = module.vpc.vpc_id
  cidrs  = var.public_cidrs
  azs    = var.azs

  name              = "${var.name}-public"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "private_app_subnet" {
  source = "./private_subnet"

  vpc_id = module.vpc.vpc_id
  cidrs  = var.private_app_cidrs
  azs    = var.azs

  type = "app"


  name              = "${var.name}-private"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "private_db_subnet" {
  source = "./private_subnet"

  vpc_id = module.vpc.vpc_id
  cidrs  = var.private_db_cidrs
  azs    = var.azs

  type = "db"

  name              = "${var.name}-private"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "security_group" {
  source = "./security_group"

  vpc_id = module.vpc.vpc_id

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

output "vpc_id" { value = module.vpc.vpc_id }

output "public_subnet_ids" { value = module.public_subnet.subnet_ids }
output "private_app_subnet_ids" { value = module.private_app_subnet.subnet_ids }
output "private_db_subnet_ids" { value = module.private_db_subnet.subnet_ids }

output "web_sg_id" { value = module.security_group.web_sg_id }
output "app_sg_id" { value = module.security_group.app_sg_id }
output "db_sg_id" { value = module.security_group.db_sg_id }
output "opmng_sg_id" { value = module.security_group.opmng_sg_id }
