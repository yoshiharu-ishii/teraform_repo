variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "web_sg_id" {}
variable "certificate_arn" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

module "alb" {
  source = "./alb"

  vpc_id          = var.vpc_id
  subnet_ids      = var.public_subnet_ids
  web_sg_id       = var.web_sg_id
  certificate_arn = var.certificate_arn

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

output "alb_arn" { value = module.alb.alb_arn }
output "appserver_target_group_arn" { value = module.alb.appserver_target_group_arn }
output "mngserver_target_group_arn" { value = module.alb.mngserver_target_group_arn }
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "alb_zone_id" { value = module.alb.alb_zone_id }
