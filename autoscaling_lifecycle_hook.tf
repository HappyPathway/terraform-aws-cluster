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
