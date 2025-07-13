variable "db_sg_id" {}
variable "subnet_ids" {}

variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

module "aurora" {
  source = "./aurora"

  db_sg_id   = var.db_sg_id
  subnet_ids = var.subnet_ids

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

output "endpoint" { value = module.aurora.endpoint }
output "username" { value = module.aurora.username }
output "password" { value = module.aurora.password }

