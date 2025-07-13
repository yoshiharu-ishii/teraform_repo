variable "name" { default = "vpc" }
variable "cidr" {}
variable "environment" {}
variable "aws-exam-resource" {}
# --------------------------------
# VPC
# --------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name              = "${var.name}"
    Env               = "${var.environment}"
    aws-exam-resource = "${var.aws-exam-resource}"
  }
}

output "vpc_id" { value = aws_vpc.vpc.id }
output "vpc_cidr" { value = aws_vpc.vpc.cidr_block }

