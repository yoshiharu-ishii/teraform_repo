variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# SNS topic
# --------------------------------
resource "aws_sns_topic" "sns_topic" {
  name = "${var.name}-topic"

  tags = {
    Name              = "${var.name}-topic"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

output "topic_arn" { value = aws_sns_topic.sns_topic.arn }
