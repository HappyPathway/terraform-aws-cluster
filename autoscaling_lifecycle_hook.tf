resource "aws_autoscaling_lifecycle_hook" "hook" {
  for_each = { for hook in var.lifecycle_hooks : hook.name => hook }

  name                    = each.value.name
  autoscaling_group_name  = one(local.autoscaling_group).name
  default_result          = each.value.default_result
  heartbeat_timeout       = each.value.heartbeat_timeout
  lifecycle_transition    = each.value.lifecycle_transition
  notification_metadata   = each.value.notification_metadata
  notification_target_arn = each.value.notification_target_arn
  role_arn                = each.value.role_arn
}

resource "aws_autoscaling_lifecycle_hook" "termination" {
  count                  = var.auto_scaling.create ? 1 : 0
  name                   = "${var.project_name}-termination-hook"
  autoscaling_group_name = aws_autoscaling_group.asg[0].name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"

  notification_metadata = jsonencode({
    action = "drain"
  })
}

resource "aws_autoscaling_lifecycle_hook" "launch" {
  count                  = var.auto_scaling.create ? 1 : 0
  name                   = "${var.project_name}-launch-hook"
  autoscaling_group_name = aws_autoscaling_group.asg[0].name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"

  notification_metadata = jsonencode({
    action = "init"
  })
}
