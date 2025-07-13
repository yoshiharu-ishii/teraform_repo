variable "vpc_id" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# Security Group
# --------------------------------
# app security group
resource "aws_security_group" "app_sg" {
  name        = "${var.name}-app-sg"
  description = "application server role security group"
  vpc_id      = var.vpc_id
  tags = {
    Name              = "${var.name}-app-sg"
    Env               = var.environment
    aws-exam-resource = true
  }
}

resource "aws_security_group_rule" "app_in" {
  security_group_id = aws_security_group.app_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_out" {
  security_group_id = aws_security_group.app_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

# db security group
resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db-sg"
  description = "database role security group"
  vpc_id      = var.vpc_id
  tags = {
    Name              = "${var.name}-db-sg"
    Env               = var.environment
    aws-exam-resource = true
  }
}

resource "aws_security_group_rule" "db_out" {
  security_group_id = aws_security_group.db_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "db_in_tcp3306" {
  security_group_id        = aws_security_group.db_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.app_sg.id
}

# web security group
resource "aws_security_group" "web_sg" {
  name        = "${var.name}-web-sg"
  description = "web front role security group"
  vpc_id      = var.vpc_id
  tags = {
    Name              = "${var.name}-web-sg"
    Env               = var.environment
    aws-exam-resource = true
  }
}

resource "aws_security_group_rule" "web_in_http" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_in_https" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_out" {
  security_group_id = aws_security_group.web_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

# opmng security group
resource "aws_security_group" "opmng_sg" {
  name        = "${var.name}-opmng-sg"
  description = "operation and management role security group"
  vpc_id      = var.vpc_id
  tags = {
    Name              = "${var.name}-opmng-sg"
    Env               = var.environment
    aws-exam-resource = true
  }
}

resource "aws_security_group_rule" "opmng_in_ssh" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opmng_out" {
  security_group_id = aws_security_group.opmng_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

output "web_sg_id" { value = aws_security_group.web_sg.id }
output "app_sg_id" { value = aws_security_group.app_sg.id }
output "db_sg_id" { value = aws_security_group.db_sg.id }
output "opmng_sg_id" { value = aws_security_group.opmng_sg.id }
