# aws_autoscaling_policy
resource "aws_autoscaling_policy" "asg_policy" {
  count = var.auto_scaling_policy == null ? 0 : 1

  name                   = var.auto_scaling_policy.name
  autoscaling_group_name = local.autoscaling_group.name
  policy_type            = var.auto_scaling_policy.policy_type

  # Policy-type specific settings
  dynamic "step_adjustment" {
    for_each = var.auto_scaling_policy.policy_type == "StepScaling" ? coalesce(var.auto_scaling_policy.step_adjustment, []) : []
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }

  dynamic "target_tracking_configuration" {
    for_each = var.auto_scaling_policy.policy_type == "TargetTrackingScaling" ? [var.auto_scaling_policy.target_tracking_configuration] : []
    content {
      dynamic "predefined_metric_specification" {
        for_each = target_tracking_configuration.value.predefined_metric_specification != null ? [target_tracking_configuration.value.predefined_metric_specification] : []
        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
          resource_label         = predefined_metric_specification.value.resource_label
        }
      }

      dynamic "customized_metric_specification" {
        for_each = target_tracking_configuration.value.customized_metric_specification != null ? [target_tracking_configuration.value.customized_metric_specification] : []
        content {
          dynamic "metric_dimension" {
            for_each = coalesce(customized_metric_specification.value.metric_dimension, [])
            content {
              name  = metric_dimension.value.name
              value = metric_dimension.value.value
            }
          }
          metric_name = customized_metric_specification.value.metric_name
          namespace   = customized_metric_specification.value.namespace
          statistic   = customized_metric_specification.value.statistic
          unit        = customized_metric_specification.value.unit
        }
      }
      target_value     = target_tracking_configuration.value.target_value
      disable_scale_in = target_tracking_configuration.value.disable_scale_in
    }
  }

  dynamic "predictive_scaling_configuration" {
    for_each = var.auto_scaling_policy.policy_type == "PredictiveScaling" ? [var.auto_scaling_policy.predictive_scaling_configuration] : []
    content {
      max_capacity_breach_behavior = predictive_scaling_configuration.value.max_capacity_breach_behavior
      max_capacity_buffer         = predictive_scaling_configuration.value.max_capacity_buffer
      mode                        = predictive_scaling_configuration.value.mode
      scheduling_buffer_time      = predictive_scaling_configuration.value.scheduling_buffer_time

      metric_specification {
        target_value = predictive_scaling_configuration.value.metric_specification.target_value
        
        dynamic "predefined_load_metric_specification" {
          for_each = predictive_scaling_configuration.value.metric_specification.predefined_load_metric_specification != null ? [predictive_scaling_configuration.value.metric_specification.predefined_load_metric_specification] : []
          content {
            predefined_metric_type = predefined_load_metric_specification.value.predefined_metric_type
            resource_label         = predefined_load_metric_specification.value.resource_label
          }
        }

        dynamic "predefined_scaling_metric_specification" {
          for_each = predictive_scaling_configuration.value.metric_specification.predefined_scaling_metric_specification != null ? [predictive_scaling_configuration.value.metric_specification.predefined_scaling_metric_specification] : []
          content {
            predefined_metric_type = predefined_scaling_metric_specification.value.predefined_metric_type
            resource_label         = predefined_scaling_metric_specification.value.resource_label
          }
        }
      }
    }
  }

  # Common settings based on policy type
  scaling_adjustment        = var.auto_scaling_policy.policy_type == "SimpleScaling" ? var.auto_scaling_policy.scaling_adjustment : null
  adjustment_type           = var.auto_scaling_policy.policy_type == "SimpleScaling" ? var.auto_scaling_policy.adjustment_type : null
  cooldown                  = var.auto_scaling_policy.policy_type == "SimpleScaling" ? var.auto_scaling_policy.cooldown : null
  metric_aggregation_type   = var.auto_scaling_policy.policy_type == "StepScaling" ? var.auto_scaling_policy.metric_aggregation_type : null
  estimated_instance_warmup = contains(["StepScaling", "TargetTrackingScaling"], var.auto_scaling_policy.policy_type) ? var.auto_scaling_policy.estimated_instance_warmup : null

  depends_on = [local.autoscaling_group]

  lifecycle {
    create_before_destroy = true
  }
}
