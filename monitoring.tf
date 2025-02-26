resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.auto_scaling.create ? 1 : 0
  alarm_name          = "${var.project_name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "60"
  statistic          = "Average"
  threshold          = "85"
  alarm_description  = "CPU utilization is too high"
  alarm_actions      = [aws_autoscaling_policy.cpu_tracking[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.auto_scaling.create ? 1 : 0
  alarm_name          = "${var.project_name}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "mem_used_percent"
  namespace           = "Morpheus"
  period             = "60"
  statistic          = "Average"
  threshold          = "85"
  alarm_description  = "Memory utilization is too high"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_usage_high" {
  count               = var.auto_scaling.create ? 1 : 0
  alarm_name          = "${var.project_name}-disk-usage-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "disk_used_percent"
  namespace           = "Morpheus"
  period             = "60"
  statistic          = "Average"
  threshold          = "85"
  alarm_description  = "Disk usage is too high"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg[0].name
    MountPath           = "/"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_rate_high" {
  count               = var.auto_scaling.create ? 1 : 0
  alarm_name          = "${var.project_name}-error-rate-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period             = "60"
  statistic          = "Sum"
  threshold          = "10"
  alarm_description  = "Application error rate is too high"

  dimensions = {
    LoadBalancer = var.autoscaling_attachment.elb
    TargetGroup  = var.autoscaling_attachment.lb_target_group_arn
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_high" {
  count               = var.auto_scaling.create ? 1 : 0
  alarm_name          = "${var.project_name}-response-time-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period             = "60"
  statistic          = "Average"
  threshold          = "2"
  alarm_description  = "Application response time is too high"

  dimensions = {
    LoadBalancer = var.autoscaling_attachment.elb
    TargetGroup  = var.autoscaling_attachment.lb_target_group_arn
  }
}

resource "aws_cloudwatch_log_group" "morpheus_app" {
  count             = var.auto_scaling.create ? 1 : 0
  name              = "/morpheus/application"
  retention_in_days = 30

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "morpheus_nginx" {
  count             = var.auto_scaling.create ? 1 : 0
  name              = "/morpheus/nginx"
  retention_in_days = 30

  tags = var.tags
}