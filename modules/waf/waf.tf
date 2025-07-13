variable "alb_arn" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# WAF
# --------------------------------
resource "aws_wafv2_web_acl" "wafv2_web_acl" {
  name        = "${var.name}-waf"
  description = "${var.name}-waf rule"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "${var.name}-waf-rule1"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Name              = "${var.name}-wafv2-web-acl"
    Env               = "${var.environment}"
    aws-exam-resource = "${var.aws-exam-resource}"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "wafv2_web_acl_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.wafv2_web_acl.arn
}
