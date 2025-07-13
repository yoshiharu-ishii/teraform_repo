variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

module "topic" {
  source = "./topic"

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

module "subscribe" {
  source = "./subscribe"

  sns_topic_arn = module.topic.topic_arn
  protocol      = "email"
  endpoint      = "su37superflanker.hal@gmail.com"

  name              = var.name
  environment       = var.environment
  aws-exam-resource = var.aws-exam-resource
}

output "topic_arn" { value = module.topic.topic_arn }
