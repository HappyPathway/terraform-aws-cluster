resource "aws_autoscaling_traffic_source_attachment" "traffic_source_attachment" {
  count                  = var.autoscaling_traffic_source_attachment == null ? 0 : 1
  autoscaling_group_name = aws_autoscaling_group.asg.id

  traffic_source {
    identifier = var.autoscaling_traffic_source_attachment.identifier
    type       = var.autoscaling_traffic_source_attachment.type
  }
}

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  count                  = var.autoscaling_attachment == null ? 0 : 1
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = var.autoscaling_attachment.elb
  lb_target_group_arn    = var.autoscaling_attachment.lb_target_group_arn
}
