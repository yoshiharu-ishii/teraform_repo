variable "vpc_id" {}
variable "subnet_ids" {}
variable "web_sg_id" {}
variable "certificate_arn" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# Target Group
# --------------------------------
resource "aws_lb_target_group" "appserver_target_group" {
  name     = "${var.name}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  tags = {
    Name              = "${var.name}-app-tg"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

# --------------------------------
# Target Group
# --------------------------------
resource "aws_lb_target_group" "mngserver_target_group" {
  name     = "${var.name}-mng-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  tags = {
    Name              = "${var.name}-mng-tg"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

# --------------------------------
# ALB
# --------------------------------
resource "aws_lb" "alb" {
  name               = "${var.name}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    var.web_sg_id
  ]
  subnets = split(",", var.subnet_ids)

  tags = {
    Name              = "${var.name}-app-alb"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name              = "${var.name}-alb-listener-http"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appserver_target_group.arn
  }

  tags = {
    Name              = "${var.name}-alb-listener-https"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

resource "aws_lb_listener_rule" "mngserver_listener_rule_https" {
  listener_arn = aws_alb_listener.alb_listener_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mngserver_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/manage/"]
    }
  }
}

output "alb_arn" { value = aws_lb.alb.arn }
output "appserver_target_group_arn" { value = aws_lb_target_group.appserver_target_group.arn }
output "mngserver_target_group_arn" { value = aws_lb_target_group.mngserver_target_group.arn }
output "alb_dns_name" { value = aws_lb.alb.dns_name }
output "alb_zone_id" { value = aws_lb.alb.zone_id }
