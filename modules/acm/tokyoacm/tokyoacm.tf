variable "domain" {}
variable "zone_id" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# Certificate
# --------------------------------
# for tokyo region
resource "aws_acm_certificate" "tokyo_cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    Name              = "${var.name}-sslcert"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "route53_acm_dns_resolove" {
  for_each = {
    for dvo in aws_acm_certificate.tokyo_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = var.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 600
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.tokyo_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_acm_dns_resolove : record.fqdn]
}


output "certificate_arn" { value = aws_acm_certificate.tokyo_cert.arn }
