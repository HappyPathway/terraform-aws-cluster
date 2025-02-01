resource "aws_autoscaling_group" "asg_launch_template" {
  count = var.auto_scaling.create && var.auto_scaling.configuration_type == "launch_template" ? 1 : 0
  name  = var.project_name

  launch_template {
    id      = local.launch_template.id
    version = local.launch_template.latest_version
  }

  min_size            = var.auto_scaling.min_size
  max_size            = var.auto_scaling.max_size
  desired_capacity    = var.auto_scaling.desired_capacity
  vpc_zone_identifier = var.auto_scaling.subnets
  placement_group     = var.placement_group == null ? null : one(aws_placement_group.pg).name

  availability_zones               = var.auto_scaling.availability_zones
  capacity_rebalance               = var.auto_scaling.capacity_rebalance
  default_cooldown                 = var.auto_scaling.default_cooldown
  default_instance_warmup          = var.auto_scaling.default_instance_warmup
  health_check_grace_period        = var.auto_scaling.health_check_grace_period
  health_check_type                = var.auto_scaling.health_check_type
  load_balancers                   = var.auto_scaling.load_balancers
  target_group_arns                = var.auto_scaling.target_group_arns
  termination_policies             = var.auto_scaling.termination_policies
  suspended_processes              = var.auto_scaling.suspended_processes
  metrics_granularity              = var.auto_scaling.metrics_granularity
  enabled_metrics                  = var.auto_scaling.enabled_metrics
  wait_for_capacity_timeout        = var.auto_scaling.wait_for_capacity_timeout
  min_elb_capacity                 = var.auto_scaling.min_elb_capacity
  wait_for_elb_capacity            = var.auto_scaling.wait_for_elb_capacity
  protect_from_scale_in            = var.auto_scaling.protect_from_scale_in
  service_linked_role_arn          = var.auto_scaling.service_linked_role_arn
  max_instance_lifetime            = var.auto_scaling.max_instance_lifetime
  force_delete                     = var.auto_scaling.force_delete
  ignore_failed_scaling_activities = var.auto_scaling.ignore_failed_scaling_activities

  desired_capacity_type = var.auto_scaling.desired_capacity_type

  dynamic "traffic_source" {
    for_each = var.auto_scaling.traffic_source == null ? [] : [1]
    content {
      identifier = var.auto_scaling.traffic_source.identifier
      type       = var.auto_scaling.traffic_source.type
    }
  }

  dynamic "instance_maintenance_policy" {
    for_each = var.auto_scaling.instance_maintenance_policy == null ? [] : [1]
    content {
      min_healthy_percentage = var.auto_scaling.instance_maintenance_policy.min_healthy_percentage
      max_healthy_percentage = var.auto_scaling.instance_maintenance_policy.max_healthy_percentage
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = var.propagate_tags_at_launch
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.auto_scaling.initial_lifecycle_hooks
    content {
      name                    = initial_lifecycle_hook.value.name
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      notification_target_arn = initial_lifecycle_hook.value.notification_target_arn
      role_arn                = initial_lifecycle_hook.value.role_arn
      notification_metadata   = initial_lifecycle_hook.value.notification_metadata
      heartbeat_timeout       = initial_lifecycle_hook.value.heartbeat_timeout
      default_result          = initial_lifecycle_hook.value.default_result
    }
  }

  dynamic "instance_refresh" {
    for_each = var.auto_scaling.instance_refresh == null ? [] : [1]
    content {
      strategy = var.auto_scaling.instance_refresh.strategy
      triggers = var.auto_scaling.instance_refresh.triggers
      dynamic "preferences" {
        for_each = var.auto_scaling.instance_refresh.preferences == null ? [] : [1]
        content {
          instance_warmup              = var.auto_scaling.instance_refresh.preferences.instance_warmup
          min_healthy_percentage       = var.auto_scaling.instance_refresh.preferences.min_healthy_percentage
          checkpoint_percentages       = var.auto_scaling.instance_refresh.preferences.checkpoint_percentages
          checkpoint_delay             = var.auto_scaling.instance_refresh.preferences.checkpoint_delay
          max_healthy_percentage       = var.auto_scaling.instance_refresh.preferences.max_healthy_percentage
          skip_matching                = var.auto_scaling.instance_refresh.preferences.skip_matching
          auto_rollback                = var.auto_scaling.instance_refresh.preferences.auto_rollback
          scale_in_protected_instances = var.auto_scaling.instance_refresh.preferences.scale_in_protected_instances
          standby_instances            = var.auto_scaling.instance_refresh.preferences.standby_instances
          dynamic "alarm_specification" {
            for_each = var.auto_scaling.instance_refresh.preferences.alarm_specification == null ? [] : [1]
            content {
              alarms = var.auto_scaling.instance_refresh.preferences.alarm_specification.alarms
            }
          }
        }
      }
    }
  }

  dynamic "warm_pool" {
    for_each = var.auto_scaling.warm_pool == null ? [] : [1]
    content {
      instance_reuse_policy {
        reuse_on_scale_in = var.auto_scaling.warm_pool.instance_reuse_policy.reuse_on_scale_in
      }
      max_group_prepared_capacity = var.auto_scaling.warm_pool.max_group_prepared_capacity
      min_size                    = var.auto_scaling.warm_pool.min_size
      pool_state                  = var.auto_scaling.warm_pool.pool_state
    }
  }
}

resource "aws_autoscaling_group" "asg_mixed_instances_policy" {
  count = var.auto_scaling.create && var.auto_scaling.configuration_type == "mixed_instances_policy" ? 1 : 0
  name  = var.project_name

  mixed_instances_policy {
    dynamic "instances_distribution" {
      for_each = var.auto_scaling.mixed_instances_policy.instances_distribution == null ? [] : [1]
      content {
        on_demand_allocation_strategy            = var.auto_scaling.mixed_instances_policy.instances_distribution.on_demand_allocation_strategy
        on_demand_base_capacity                  = var.auto_scaling.mixed_instances_policy.instances_distribution.on_demand_base_capacity
        on_demand_percentage_above_base_capacity = var.auto_scaling.mixed_instances_policy.instances_distribution.on_demand_percentage_above_base_capacity
        spot_allocation_strategy                 = var.auto_scaling.mixed_instances_policy.instances_distribution.spot_allocation_strategy
        spot_instance_pools                      = var.auto_scaling.mixed_instances_policy.instances_distribution.spot_instance_pools
        spot_max_price                           = var.auto_scaling.mixed_instances_policy.instances_distribution.spot_max_price
      }
    }

    dynamic "launch_template" {
      for_each = var.auto_scaling.mixed_instances_policy.launch_template == null ? [] : [1]
      content {
        launch_template_specification {
          launch_template_id = var.var.auto_scaling.mixed_instances_policy.launch_template.create ? local.launch_template.id : var.auto_scaling.mixed_instances_policy.launch_template.launch_template_specification.launch_template_id
          version            = var.var.auto_scaling.mixed_instances_policy.launch_template.create ? local.launch_template.version : var.auto_scaling.mixed_instances_policy.launch_template.launch_template_specification.version
        }
      }
    }
  }

  min_size            = var.auto_scaling.min_size
  max_size            = var.auto_scaling.max_size
  desired_capacity    = var.auto_scaling.desired_capacity
  vpc_zone_identifier = var.auto_scaling.subnets
  placement_group     = var.placement_group == null ? null : one(aws_placement_group.pg).name

  availability_zones               = var.auto_scaling.availability_zones
  capacity_rebalance               = var.auto_scaling.capacity_rebalance
  default_cooldown                 = var.auto_scaling.default_cooldown
  default_instance_warmup          = var.auto_scaling.default_instance_warmup
  health_check_grace_period        = var.auto_scaling.health_check_grace_period
  health_check_type                = var.auto_scaling.health_check_type
  load_balancers                   = var.auto_scaling.load_balancers
  target_group_arns                = var.auto_scaling.target_group_arns
  termination_policies             = var.auto_scaling.termination_policies
  suspended_processes              = var.auto_scaling.suspended_processes
  metrics_granularity              = var.auto_scaling.metrics_granularity
  enabled_metrics                  = var.auto_scaling.enabled_metrics
  wait_for_capacity_timeout        = var.auto_scaling.wait_for_capacity_timeout
  min_elb_capacity                 = var.auto_scaling.min_elb_capacity
  wait_for_elb_capacity            = var.auto_scaling.wait_for_elb_capacity
  protect_from_scale_in            = var.auto_scaling.protect_from_scale_in
  service_linked_role_arn          = var.auto_scaling.service_linked_role_arn
  max_instance_lifetime            = var.auto_scaling.max_instance_lifetime
  force_delete                     = var.auto_scaling.force_delete
  ignore_failed_scaling_activities = var.auto_scaling.ignore_failed_scaling_activities

  desired_capacity_type = var.auto_scaling.desired_capacity_type

  dynamic "traffic_source" {
    for_each = var.auto_scaling.traffic_source == null ? [] : [1]
    content {
      identifier = var.auto_scaling.traffic_source.identifier
      type       = var.auto_scaling.traffic_source.type
    }
  }

  dynamic "instance_maintenance_policy" {
    for_each = var.auto_scaling.instance_maintenance_policy == null ? [] : [1]
    content {
      min_healthy_percentage = var.auto_scaling.instance_maintenance_policy.min_healthy_percentage
      max_healthy_percentage = var.auto_scaling.instance_maintenance_policy.max_healthy_percentage
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = var.propagate_tags_at_launch
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.auto_scaling.initial_lifecycle_hooks
    content {
      name                    = initial_lifecycle_hook.value.name
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      notification_target_arn = initial_lifecycle_hook.value.notification_target_arn
      role_arn                = initial_lifecycle_hook.value.role_arn
      notification_metadata   = initial_lifecycle_hook.value.notification_metadata
      heartbeat_timeout       = initial_lifecycle_hook.value.heartbeat_timeout
      default_result          = initial_lifecycle_hook.value.default_result
    }
  }

  dynamic "instance_refresh" {
    for_each = var.auto_scaling.instance_refresh == null ? [] : [1]
    content {
      strategy = var.auto_scaling.instance_refresh.strategy
      triggers = var.auto_scaling.instance_refresh.triggers
      dynamic "preferences" {
        for_each = var.auto_scaling.instance_refresh.preferences == null ? [] : [1]
        content {
          instance_warmup              = var.auto_scaling.instance_refresh.preferences.instance_warmup
          min_healthy_percentage       = var.auto_scaling.instance_refresh.preferences.min_healthy_percentage
          checkpoint_percentages       = var.auto_scaling.instance_refresh.preferences.checkpoint_percentages
          checkpoint_delay             = var.auto_scaling.instance_refresh.preferences.checkpoint_delay
          max_healthy_percentage       = var.auto_scaling.instance_refresh.preferences.max_healthy_percentage
          skip_matching                = var.auto_scaling.instance_refresh.preferences.skip_matching
          auto_rollback                = var.auto_scaling.instance_refresh.preferences.auto_rollback
          scale_in_protected_instances = var.auto_scaling.instance_refresh.preferences.scale_in_protected_instances
          standby_instances            = var.auto_scaling.instance_refresh.preferences.standby_instances
          dynamic "alarm_specification" {
            for_each = var.auto_scaling.instance_refresh.preferences.alarm_specification == null ? [] : [1]
            content {
              alarms = var.auto_scaling.instance_refresh.preferences.alarm_specification.alarms
            }
          }
        }
      }
    }
  }

  dynamic "warm_pool" {
    for_each = var.auto_scaling.warm_pool == null ? [] : [1]
    content {
      instance_reuse_policy {
        reuse_on_scale_in = var.auto_scaling.warm_pool.instance_reuse_policy.reuse_on_scale_in
      }
      max_group_prepared_capacity = var.auto_scaling.warm_pool.max_group_prepared_capacity
      min_size                    = var.auto_scaling.warm_pool.min_size
      pool_state                  = var.auto_scaling.warm_pool.pool_state
    }
  }
}

data "aws_autoscaling_group" "asg" {
  count = var.auto_scaling.create ? 0 : 1
  name  = var.project_name
}

locals {
  autoscaling_groups = {
    data_source            = one(data.aws_autoscaling_group.asg)
    launch_template        = one(aws_autoscaling_group.asg_launch_template)
    mixed_instances_policy = one(aws_autoscaling_group.asg_mixed_instances_policy)
  }

  autoscaling_group = var.auto_scaling.create ? lookup(local.autoscaling_groups, var.auto_scaling.configuration_type) : lookup(local.autoscaling_groups, "data_source")
}
