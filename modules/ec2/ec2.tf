variable "app_ami_id" {}
variable "bastion_ami_id" {}

variable "app_sg_id" {}
variable "opmng_sg_id" {}


variable "private_app_subnet_ids" {}
variable "public_subnet_ids" {}

variable "appserver_target_group_arn" {}
variable "mngserver_target_group_arn" {}

variable "endpoint" {}
variable "username" {}
variable "password" {}
variable "examineeid" {}

variable "topic_arn" {}

variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
#  EC2全般の構築
# --------------------------------
module "keypair" {
  source = "./keypair"

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

# アプリケーションサーバ
module "appserver" {
  source = "./asgserver"

  ami_id       = var.app_ami_id
  keypair_name = module.keypair.keypair_name
  app_sg_id    = var.app_sg_id

  subnet_ids           = var.private_app_subnet_ids
  alb_target_group_arn = var.appserver_target_group_arn

  min_size         = 1
  max_size         = 4
  desired_capacity = 1


  endpoint   = var.endpoint
  username   = var.username
  password   = var.password
  examineeid = var.examineeid

  type = "app"

  topic_arn = var.topic_arn

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "mngserver" {
  source = "./asgserver"

  ami_id       = var.app_ami_id
  keypair_name = module.keypair.keypair_name
  app_sg_id    = var.app_sg_id

  subnet_ids           = var.private_app_subnet_ids
  alb_target_group_arn = var.mngserver_target_group_arn

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  endpoint   = var.endpoint
  username   = var.username
  password   = var.password
  examineeid = var.examineeid

  type = "mng"

  topic_arn = var.topic_arn

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "bastionserver" {
  source = "./bastionserver"

  ami_id       = var.bastion_ami_id
  keypair_name = module.keypair.keypair_name
  opmng_sg_id  = var.opmng_sg_id

  subnet_ids = var.public_subnet_ids

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}
