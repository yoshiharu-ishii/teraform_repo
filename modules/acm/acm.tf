variable "domain" {}
variable "zone_id" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

module "acm" {
  source = "./tokyoacm"

  domain  = var.domain
  zone_id = var.zone_id

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

output "certificate_arn" { value = module.acm.certificate_arn }
