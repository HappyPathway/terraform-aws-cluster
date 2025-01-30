# aws_autoscaling_policy
resource "aws_autoscaling_policy" "asg_policy" {
  count                     = var.auto_scaling_policy == null ? 0 : 1
  name                      = var.auto_scaling_policy.name
  scaling_adjustment        = var.auto_scaling_policy.scaling_adjustment
  adjustment_type           = var.auto_scaling_policy.adjustment_type
  cooldown                  = var.auto_scaling_policy.cooldown
  policy_type               = var.auto_scaling_policy.policy_type
  estimated_instance_warmup = var.auto_scaling_policy.estimated_instance_warmup
  autoscaling_group_name    = local.autoscaling_group.name
  depends_on                = [local.autoscaling_group]

  # Optional attributes for StepScaling policies
  metric_aggregation_type = var.auto_scaling_policy.metric_aggregation_type
  dynamic "step_adjustment" {
    for_each = var.auto_scaling_policy.step_adjustment == null ? [] : var.auto_scaling_policy.step_adjustment
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }

  # Optional attributes for TargetTrackingScaling policies
  dynamic "target_tracking_configuration" {
    for_each = var.auto_scaling_policy.target_tracking_configuration == null ? [] : [var.auto_scaling_policy.target_tracking_configuration]
    content {
      predefined_metric_specification {
        predefined_metric_type = target_tracking_configuration.value.predefined_metric_specification.predefined_metric_type
        resource_label         = target_tracking_configuration.value.predefined_metric_specification.resource_label
      }
      customized_metric_specification {
        dynamic "metric_dimension" {
          for_each = target_tracking_configuration.value.customized_metric_specification.metric_dimension == null ? [] : target_tracking_configuration.value.customized_metric_specification.metric_dimension
          content {
            name  = metric_dimension.value.name
            value = metric_dimension.value.value
          }
        }
        metric_name = target_tracking_configuration.value.customized_metric_specification.metric_name
        namespace   = target_tracking_configuration.value.customized_metric_specification.namespace
        statistic   = target_tracking_configuration.value.customized_metric_specification.statistic
        unit        = target_tracking_configuration.value.customized_metric_specification.unit
        dynamic "metrics" {
          for_each = target_tracking_configuration.value.customized_metric_specification.metrics == null ? [] : target_tracking_configuration.value.customized_metric_specification.metrics
          content {
            expression = metrics.value.expression
            id         = metrics.value.id
            label      = metrics.value.label
            metric_stat {
              metric {
                dynamic "dimensions" {
                  for_each = metrics.value.metric_stat.metric.dimensions == null ? [] : metrics.value.metric_stat.metric.dimensions
                  content {
                    name  = dimensions.value.name
                    value = dimensions.value.value
                  }
                }
                metric_name = metrics.value.metric_stat.metric.metric_name
                namespace   = metrics.value.metric_stat.metric.namespace
              }
              stat = metrics.value.metric_stat.stat
              unit = metrics.value.metric_stat.unit
            }
            return_data = metrics.value.return_data
          }
        }
      }
      target_value     = target_tracking_configuration.value.target_value
      disable_scale_in = target_tracking_configuration.value.disable_scale_in
    }
  }

  # Optional attributes for PredictiveScaling policies
  dynamic "predictive_scaling_configuration" {
    for_each = var.auto_scaling_policy.predictive_scaling_configuration == null ? [] : [var.auto_scaling_policy.predictive_scaling_configuration]
    content {
      max_capacity_breach_behavior = predictive_scaling_configuration.value.max_capacity_breach_behavior
      max_capacity_buffer          = predictive_scaling_configuration.value.max_capacity_buffer
      metric_specification {
        target_value = predictive_scaling_configuration.value.metric_specification.target_value
        dynamic "customized_capacity_metric_specification" {
          for_each = predictive_scaling_configuration.value.metric_specification.customized_capacity_metric_specification == null ? [] : [predictive_scaling_configuration.value.metric_specification.customized_capacity_metric_specification]
          content {
            dynamic "metric_data_queries" {
              for_each = customized_capacity_metric_specification.value.metric_data_queries == null ? [] : customized_capacity_metric_specification.value.metric_data_queries
              content {
                expression = metric_data_queries.value.expression
                id         = metric_data_queries.value.id
                label      = metric_data_queries.value.label
                metric_stat {
                  metric {
                    dynamic "dimensions" {
                      for_each = metric_data_queries.value.metric_stat.metric.dimensions == null ? [] : metric_data_queries.value.metric_stat.metric.dimensions
                      content {
                        name  = dimensions.value.name
                        value = dimensions.value.value
                      }
                    }
                    metric_name = metric_data_queries.value.metric_stat.metric.metric_name
                    namespace   = metric_data_queries.value.metric_stat.metric.namespace
                  }
                  stat = metric_data_queries.value.metric_stat.stat
                  unit = metric_data_queries.value.metric_stat.unit
                }
                return_data = metric_data_queries.value.return_data
              }
            }
          }
        }
        dynamic "customized_load_metric_specification" {
          for_each = predictive_scaling_configuration.value.metric_specification.customized_load_metric_specification == null ? [] : [predictive_scaling_configuration.value.metric_specification.customized_load_metric_specification]
          content {
            dynamic "metric_data_queries" {
              for_each = customized_load_metric_specification.value.metric_data_queries == null ? [] : customized_load_metric_specification.value.metric_data_queries
              content {
                expression = metric_data_queries.value.expression
                id         = metric_data_queries.value.id
                label      = metric_data_queries.value.label
                metric_stat {
                  metric {
                    dynamic "dimensions" {
                      for_each = metric_data_queries.value.metric_stat.metric.dimensions == null ? [] : metric_data_queries.value.metric_stat.metric.dimensions
                      content {
                        name  = dimensions.value.name
                        value = dimensions.value.value
                      }
                    }
                    metric_name = metric_data_queries.value.metric_stat.metric.metric_name
                    namespace   = metric_data_queries.value.metric_stat.metric.namespace
                  }
                  stat = metric_data_queries.value.metric_stat.stat
                  unit = metric_data_queries.value.metric_stat.unit
                }
                return_data = metric_data_queries.value.return_data
              }
            }
          }
        }
        dynamic "customized_scaling_metric_specification" {
          for_each = predictive_scaling_configuration.value.metric_specification.customized_scaling_metric_specification == null ? [] : [predictive_scaling_configuration.value.metric_specification.customized_scaling_metric_specification]
          content {
            dynamic "metric_data_queries" {
              for_each = customized_scaling_metric_specification.value.metric_data_queries == null ? [] : customized_scaling_metric_specification.value.metric_data_queries
              content {
                expression = metric_data_queries.value.expression
                id         = metric_data_queries.value.id
                label      = metric_data_queries.value.label
                metric_stat {
                  metric {
                    dynamic "dimensions" {
                      for_each = metric_data_queries.value.metric_stat.metric.dimensions == null ? [] : metric_data_queries.value.metric_stat.metric.dimensions
                      content {
                        name  = dimensions.value.name
                        value = dimensions.value.value
                      }
                    }
                    metric_name = metric_data_queries.value.metric_stat.metric.metric_name
                    namespace   = metric_data_queries.value.metric_stat.metric.namespace
                  }
                  stat = metric_data_queries.value.metric_stat.stat
                  unit = metric_data_queries.value.metric_stat.unit
                }
                return_data = metric_data_queries.value.return_data
              }
            }
          }
        }
        predefined_load_metric_specification {
          predefined_metric_type = metric_specification.value.predefined_load_metric_specification.predefined_metric_type
          resource_label         = metric_specification.value.predefined_load_metric_specification.resource_label
        }
        predefined_metric_pair_specification {
          predefined_metric_type = metric_specification.value.predefined_metric_pair_specification.predefined_metric_type
          resource_label         = metric_specification.value.predefined_metric_pair_specification.resource_label
        }
        predefined_scaling_metric_specification {
          predefined_metric_type = metric_specification.value.predefined_scaling_metric_specification.predefined_metric_type
          resource_label         = metric_specification.value.predefined_scaling_metric_specification.resource_label
        }
      }
      mode                   = predictive_scaling_configuration.value.mode
      scheduling_buffer_time = predictive_scaling_configuration.value.scheduling_buffer_time
    }
  }
}
