variable "auto_scaling" {
  description = "Configuration for the Auto Scaling Group"
  type = object({
    project_name                     = string
    min_size                         = number
    max_size                         = number
    desired_capacity                 = number
    subnets                          = list(string)
    availability_zones               = optional(list(string), [])
    capacity_rebalance               = optional(bool, false)
    default_cooldown                 = optional(number, 300)
    default_instance_warmup          = optional(number, 300)
    health_check_grace_period        = optional(number, 300)
    health_check_type                = optional(string, "EC2")
    load_balancers                   = optional(list(string), [])
    target_group_arns                = optional(list(string), [])
    termination_policies             = optional(list(string), [])
    suspended_processes              = optional(list(string), [])
    metrics_granularity              = optional(string, "1Minute")
    enabled_metrics                  = optional(list(string), [])
    wait_for_capacity_timeout        = optional(string, "10m")
    min_elb_capacity                 = optional(number, 0)
    wait_for_elb_capacity            = optional(number, 0)
    protect_from_scale_in            = optional(bool, false)
    service_linked_role_arn          = optional(string, null)
    max_instance_lifetime            = optional(number, 0)
    force_delete                     = optional(bool, false)
    ignore_failed_scaling_activities = optional(bool, false)
    desired_capacity_type            = optional(string, "units")
    traffic_source = optional(object({
      identifier = string
      type       = string
    }), null)
    instance_maintenance_policy = optional(object({
      min_healthy_percentage = number
      max_healthy_percentage = number
    }), null)
    initial_lifecycle_hooks = optional(list(object({
      name                    = string
      lifecycle_transition    = string
      notification_target_arn = string
      role_arn                = string
      notification_metadata   = optional(string, null)
      heartbeat_timeout       = optional(number, 3600)
      default_result          = optional(string, "CONTINUE")
    })), [])
    instance_refresh = optional(object({
      strategy = string
      triggers = optional(list(string), [])
      preferences = optional(object({
        instance_warmup              = optional(number, 300)
        min_healthy_percentage       = optional(number, 90)
        checkpoint_percentages       = optional(list(number), [])
        checkpoint_delay             = optional(number, 3600)
        max_healthy_percentage       = optional(number, 100)
        skip_matching                = optional(bool, false)
        auto_rollback                = optional(bool, false)
        scale_in_protected_instances = optional(string, "Ignore")
        standby_instances            = optional(string, "Ignore")
        alarm_specification = optional(object({
          alarms = list(string)
        }), null)
      }), null)
    }), null)
    warm_pool = optional(object({
      instance_reuse_policy = optional(object({
        reuse_on_scale_in = optional(bool, false)
      }), null)
      max_group_prepared_capacity = optional(number, 0)
      min_size                    = optional(number, 0)
      pool_state                  = optional(string, "Stopped")
    }), null)
  })
}
