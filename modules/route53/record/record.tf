variable "domain" {}
variable "zone_id" {}
variable "alb_dns_name" {}
variable "alb_zone_id" {}

variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# Route53 Record
# --------------------------------
resource "aws_route53_record" "route53_record" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
