resource "aws_autoscaling_schedule" "asg_schedule" {
  for_each               = { for schedule in var.autoscaling_schedule : schedule.scheduled_action_name => schedule }
  autoscaling_group_name = one(aws_autoscaling_group.asg).id
  scheduled_action_name  = each.value.scheduled_action_name
  start_time             = each.value.start_time
  end_time               = each.value.end_time
  recurrence             = each.value.recurrence
  min_size               = each.value.min_size
  max_size               = each.value.max_size
  desired_capacity       = each.value.desired_capacity
}
