variable "ami_id" {}
variable "keypair_name" {}
variable "app_sg_id" {}
variable "subnet_ids" {}
variable "alb_target_group_arn" {}

variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}

variable "endpoint" {}
variable "username" {}
variable "password" {}
variable "examineeid" {}

variable "type" {}

variable "topic_arn" {}

variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }


# --------------------------------
# user data
# --------------------------------
data "template_file" "user_data" {
  template = file("${path.module}/userdata.txt.tpl")

  vars = {
    endpoint   = var.endpoint
    dbuser     = var.username
    dbpass     = var.password
    examineeid = var.examineeid
  }
}

# --------------------------------
# server launch template
# --------------------------------
resource "aws_launch_template" "launch_template" {
  update_default_version = true

  name = "${var.name}-${var.type}-launch-template"

  image_id = var.ami_id

  key_name = var.keypair_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name              = "${var.name}-${var.type}-ec2"
      Env               = var.environment
      aws-exam-resource = var.aws-exam-resource
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
    delete_on_termination       = true
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

# --------------------------------
# auto scaling group
# --------------------------------
resource "aws_autoscaling_group" "asg" {
  name = "${var.name}-${var.type}-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = split(",", var.subnet_ids)
  target_group_arns   = [var.alb_target_group_arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template.id
        version            = "$Latest"
      }
      override {
        instance_type = "t3.small"
      }
    }
  }

  enabled_metrics = [
    "GroupMinSize"
    , "GroupMaxSize"
    , "GroupDesiredCapacity"
    , "GroupInServiceInstances"
    , "GroupPendingInstances"
    , "GroupStandbyInstances"
    , "GroupTerminatingInstances"
    , "GroupTotalInstances"
    , "GroupInServiceCapacity"
    , "GroupPendingCapacity"
    , "GroupStandbyCapacity"
    , "GroupTerminatingCapacity"
    , "GroupTotalCapacity"
    , "WarmPoolDesiredCapacity"
    , "WarmPoolWarmedCapacity"
    , "WarmPoolPendingCapacity"
    , "WarmPoolTerminatingCapacity"
    , "WarmPoolTotalCapacity"
    , "GroupAndWarmPoolDesiredCapacity"
    , "GroupAndWarmPoolTotalCapacity"
  ]

  metrics_granularity = "1Minute"
}

# --------------------------------
# auto scaling policy
# --------------------------------
resource "aws_autoscaling_policy" "scaling_policy" {
  name            = "${var.name}-${var.type}-scaling-policy"
  adjustment_type = "ChangeInCapacity"
  policy_type     = "StepScaling"

  # CPUの平均使用率が50%-100%の場合EC2を4つ増やす
  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 4
  }
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alerm" {
  alarm_name          = "${var.name}-${var.type}-scale-out-alerm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  # Step ScalingのCPU平均使用率の閾値の基準は50%とする
  threshold = 50

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scaling_policy.arn, var.topic_arn]

  tags = {
    Name              = "${var.name}-${var.type}-metric-alarm"
    Env               = var.environment
    Type              = var.type
    aws-exam-resource = true
  }
}
