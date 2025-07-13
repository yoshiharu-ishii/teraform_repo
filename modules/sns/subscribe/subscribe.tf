variable "sns_topic_arn" {}
variable "protocol" {}
variable "endpoint" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# SNS Subscribe
# --------------------------------
resource "aws_sns_topic_subscription" "sns_topic_email_subscription" {
  topic_arn = var.sns_topic_arn
  protocol  = var.protocol
  endpoint  = var.endpoint
}
