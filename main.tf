# --------------------------------
# Terraform configuration
# --------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

# --------------------------------
# Provider
# --------------------------------
provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
  assume_role {
    role_arn = ""
  }
}

# --------------------------------
# Variables
# --------------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "examineeid" {
  type = string
}

variable "aws-exam-resource" {
  type = bool
}

variable "domain" {
  type = string
}

variable "zone_id" {
  type = string
}

# --------------------------------
# デフォルト設定
# --------------------------------
# EBSのデフォルト暗号化
resource "aws_ebs_encryption_by_default" "ebs_encryption_by_default" {
  enabled = true
}

# --------------------------------
# modules
# --------------------------------
module "network" {
  # VPC
  source   = "./modules/network"
  vpc_cidr = "192.168.0.0/20"

  azs = "ap-northeast-1a,ap-northeast-1c"

  # Public Subnet
  public_cidrs = "192.168.1.0/24,192.168.2.0/24"

  # Private App Subnet
  private_app_cidrs = "192.168.3.0/24,192.168.4.0/24"
  # Private Db Subnet
  private_db_cidrs = "192.168.5.0/24,192.168.6.0/24"

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "sns" {
  source = "./modules/sns"

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "acm" {
  source = "./modules/acm"

  domain  = var.domain
  zone_id = var.zone_id

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "elb" {
  source = "./modules/elb"

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  web_sg_id         = module.network.web_sg_id
  certificate_arn   = module.acm.certificate_arn

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "waf" {
  source = "./modules/waf"

  alb_arn = module.elb.alb_arn

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "route53_record" {
  source = "./modules/route53/record"

  domain       = var.domain
  zone_id      = var.zone_id
  alb_dns_name = module.elb.alb_dns_name
  alb_zone_id  = module.elb.alb_zone_id

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}


module "database" {
  source = "./modules/database"

  db_sg_id   = module.network.db_sg_id
  subnet_ids = module.network.private_db_subnet_ids

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "ec2" {
  source = "./modules/ec2"

  app_ami_id     = data.aws_ami.app.image_id
  bastion_ami_id = data.aws_ami.bastion.image_id
  app_sg_id      = module.network.app_sg_id
  opmng_sg_id    = module.network.opmng_sg_id

  private_app_subnet_ids = module.network.private_app_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids

  appserver_target_group_arn = module.elb.appserver_target_group_arn
  mngserver_target_group_arn = module.elb.mngserver_target_group_arn

  endpoint   = module.database.endpoint
  username   = module.database.username
  password   = module.database.password
  examineeid = var.examineeid

  topic_arn = module.sns.topic_arn

  # 共通パラメータ
  name              = "${var.project}-${var.environment}"
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}
