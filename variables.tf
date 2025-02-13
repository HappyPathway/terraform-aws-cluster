variable "ami" {
  description = "Configuration for the AMI data source"
  type = object({
    most_recent      = optional(bool, true)
    owners           = optional(list(string), null)
    executable_users = optional(list(string), null)
    name_regex       = optional(string, null)
    filters = optional(list(object({
      name   = string
      values = list(string)
    })), [])
  })
}

variable "auto_scaling" {
  description = "Configuration for the auto scaling group. Requires min_size, max_size, and desired_capacity to be set when create is true."
  type = object({
    create                           = bool
    min_size                         = number
    max_size                         = number
    desired_capacity                 = number
    subnets                          = optional(list(string), null)
    availability_zones               = optional(list(string), null)
    capacity_rebalance               = optional(bool, true)  # Changed default to true for better availability
    default_cooldown                 = optional(number, 300)
    default_instance_warmup          = optional(number, 300)
    health_check_grace_period        = optional(number, 300)
    health_check_type                = optional(string, "ELB") # Changed default to ELB for better reliability
    load_balancers                   = optional(list(string), [])
    target_group_arns                = optional(list(string), [])
    termination_policies             = optional(list(string), ["Default"]) # Added default termination policy
    suspended_processes              = optional(list(string), [])
    metrics_granularity              = optional(string, "1Minute")
    enabled_metrics                  = optional(list(string), [
      "GroupMinSize",
      "GroupMaxSize",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupPendingInstances",
      "GroupStandbyInstances",
      "GroupTerminatingInstances",
      "GroupTotalInstances"
    ]) # Added default metrics for better monitoring
    wait_for_capacity_timeout        = optional(string, "10m")
    min_elb_capacity                 = optional(number, null)
    wait_for_elb_capacity            = optional(number, null)
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
      triggers = optional(list(string), ["tag", "launch_template"])  # Added default triggers
      preferences = optional(object({
        instance_warmup              = optional(number, 300)
        min_healthy_percentage       = optional(number, 90)
        checkpoint_percentages       = optional(list(number), [20, 40, 60, 80, 100])  # Added default checkpoints
        checkpoint_delay             = optional(number, 300)
        max_healthy_percentage       = optional(number, 100)
        skip_matching                = optional(bool, false)
        auto_rollback                = optional(bool, true)  # Changed default to true
        scale_in_protected_instances = optional(string, "WAIT")  # Added default behavior
        standby_instances            = optional(string, "TERMINATE")  # Added default behavior
        alarm_specification = optional(object({
          alarms = list(string)
        }), null)
      }), {})  # Changed to empty object default instead of null
    }), null)
    warm_pool = optional(object({
      instance_reuse_policy = optional(object({
        reuse_on_scale_in = bool
      }), null)
      max_group_prepared_capacity = optional(number, 0)
      min_size                    = optional(number, 0)
      pool_state                  = optional(string, "Stopped")
    }), null)
    mixed_instances_policy = optional(object({
      instances_distribution = optional(object({
        on_demand_allocation_strategy            = optional(string, "prioritized")
        on_demand_base_capacity                  = optional(number, 0)
        on_demand_percentage_above_base_capacity = optional(number, 100)
        spot_allocation_strategy                 = optional(string, "lowest-price")
        spot_instance_pools                      = optional(number, 2)
        spot_max_price                           = optional(string, "")
      }), null)
      launch_template = optional(object({
        launch_template_specification = object({
          launch_template_id = string
          version            = optional(string, "$Latest")
        })
        override = optional(list(object({
          instance_type = string
        })), [])
      }), null)
    }), null)
  })
  default = {
    create           = false
    min_size         = 0
    max_size         = 0
    desired_capacity = 0
    subnets          = []
  }

  validation {
    condition     = !var.auto_scaling.create || (var.auto_scaling.min_size <= var.auto_scaling.desired_capacity && var.auto_scaling.desired_capacity <= var.auto_scaling.max_size)
    error_message = "When create is true, desired_capacity must be between min_size and max_size."
  }

  validation {
    condition     = !var.auto_scaling.create || var.auto_scaling.max_size > 0
    error_message = "When create is true, max_size must be greater than 0."
  }

  validation {
    condition     = !var.auto_scaling.create || (var.auto_scaling.subnets != null || var.auto_scaling.availability_zones != null)
    error_message = "When create is true, either subnets or availability_zones must be specified."
  }

  validation {
    condition     = contains(["EC2", "ELB"], var.auto_scaling.health_check_type)
    error_message = "health_check_type must be either 'EC2' or 'ELB'."
  }

  validation {
    condition     = var.auto_scaling.instance_refresh == null || contains(["Rolling"], var.auto_scaling.instance_refresh.strategy)
    error_message = "instance_refresh strategy must be 'Rolling' when specified."
  }

  validation {
    condition     = var.auto_scaling.instance_refresh == null || var.auto_scaling.instance_refresh.preferences == null || var.auto_scaling.instance_refresh.preferences.min_healthy_percentage >= 0 && var.auto_scaling.instance_refresh.preferences.min_healthy_percentage <= 100
    error_message = "min_healthy_percentage must be between 0 and 100."
  }

  validation {
    condition     = var.auto_scaling.instance_refresh == null || var.auto_scaling.instance_refresh.preferences == null || var.auto_scaling.instance_refresh.preferences.scale_in_protected_instances == null || contains(["REFRESH", "WAIT", "STANDBY"], var.auto_scaling.instance_refresh.preferences.scale_in_protected_instances)
    error_message = "scale_in_protected_instances must be one of: REFRESH, WAIT, or STANDBY."
  }
}

variable "auto_scaling_policy" {
  description = "Configuration for the auto scaling policy. Supports target tracking, step scaling, and predictive scaling."
  type = object({
    name                      = string
    policy_type               = optional(string, "TargetTrackingScaling") # Changed default to target tracking
    scaling_adjustment        = optional(number)
    adjustment_type           = optional(string, "ChangeInCapacity")
    cooldown                  = optional(number, 300)
    estimated_instance_warmup = optional(number, 300)
    metric_aggregation_type   = optional(string, "Average")
    
    # Enhanced step scaling configuration
    step_adjustment = optional(list(object({
      scaling_adjustment          = number
      metric_interval_lower_bound = optional(number, 0)
      metric_interval_upper_bound = optional(number)
    })))
    
    # Improved target tracking configuration
    target_tracking_configuration = optional(object({
      predefined_metric_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))
      customized_metric_specification = optional(object({
        metric_dimension = optional(list(object({
          name  = string
          value = string
        })))
        metric_name = string
        namespace   = string
        statistic   = optional(string, "Average")
        unit        = optional(string)
      }))
      target_value     = number
      disable_scale_in = optional(bool, false)
    }))

    # Enhanced predictive scaling configuration
    predictive_scaling_configuration = optional(object({
      max_capacity_breach_behavior = optional(string, "HonorMaxCapacity")
      max_capacity_buffer         = optional(number, 0)
      scheduling_buffer_time      = optional(number, 300)
      mode                        = optional(string, "ForecastAndScale")
      metric_specification = object({
        target_value = number
        predefined_load_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = string
        }))
        predefined_scaling_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = string
        }))
      })
    }))
  })
  default = null

  validation {
    condition     = var.auto_scaling_policy == null || contains(["SimpleScaling", "StepScaling", "TargetTrackingScaling", "PredictiveScaling"], var.auto_scaling_policy.policy_type)
    error_message = "policy_type must be one of: SimpleScaling, StepScaling, TargetTrackingScaling, or PredictiveScaling"
  }

  validation {
    condition     = var.auto_scaling_policy == null || var.auto_scaling_policy.target_tracking_configuration == null || var.auto_scaling_policy.target_tracking_configuration.target_value > 0
    error_message = "target_value in target_tracking_configuration must be greater than 0"
  }

  validation {
    condition     = var.auto_scaling_policy == null || var.auto_scaling_policy.cooldown == null || var.auto_scaling_policy.cooldown >= 0
    error_message = "cooldown period must be greater than or equal to 0"
  }

  validation {
    condition     = var.auto_scaling_policy == null || var.auto_scaling_policy.estimated_instance_warmup == null || var.auto_scaling_policy.estimated_instance_warmup >= 0
    error_message = "estimated_instance_warmup must be greater than or equal to 0"
  }
}

variable "autoscaling_attachment" {
  description = "Configuration for the autoscaling attachment"
  type = object({
    elb                 = string
    lb_target_group_arn = string
  })
  default = null
}

variable "autoscaling_schedule" {
  description = "List of autoscaling schedules"
  type = list(object({
    scheduled_action_name = string
    start_time            = optional(string)
    end_time              = optional(string)
    recurrence            = optional(string)
    min_size              = optional(number)
    max_size              = optional(number)
    desired_capacity      = optional(number)
  }))
  default = []
}

variable "autoscaling_traffic_source_attachment" {
  description = "Configuration for the autoscaling traffic source attachment"
  type = object({
    identifier = string
    type       = string
  })
  default = null
}

variable "cloud_init_config" {
  description = "Cloud-init configuration that will be appended to user-data for the launch configuration"
  type = list(object({
    path    = string
    content = string
  }))
  default = []
}

variable "file_list" {
  description = "List of files to be included in the configuration"
  type = list(object({
    filename     = string
    content_type = string
  }))
  default = []
}

variable "instance_type" {
  description = "Instance type that will be used for the launch configuration"
  type        = string
}

variable "launch_template" {
  description = "Configuration for the launch template"
  type = object({
    create              = optional(bool, false)
    use_launch_template = optional(bool, true)
    name                = optional(string, null)
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = object({
        volume_size = number
        volume_type = string
      })
    })), [])
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = string
    }), null)
    cpu_options = optional(object({
      core_count       = number
      threads_per_core = number
    }), null)
    credit_specification = optional(object({
      cpu_credits = string
    }), null)
    disable_api_stop        = optional(bool, false)
    disable_api_termination = optional(bool, false)
    ebs_optimized           = optional(bool, false)
    elastic_gpu_specifications = optional(object({
      type = string
    }), null)
    elastic_inference_accelerator = optional(object({
      type = string
    }), null)
    enclave_options = optional(object({
      enabled = bool
    }), null)
    hibernation_options = optional(object({
      configured = bool
    }), null)
    iam_instance_profile = optional(object({
      name = string
    }), null)
    instance_market_options = optional(object({
      market_type = string
      spot_options = object({
        block_duration_minutes         = number
        instance_interruption_behavior = string
        max_price                      = string
        spot_instance_type             = string
        valid_until                    = string
      })
    }), null)
    instance_requirements = optional(object({
      vcpu_count = optional(object({
        min = number
        max = number
      }), null)
      memory_mib = optional(object({
        min = number
        max = number
      }), null)
    }), null)

    kernel_id      = optional(string)
    key_name       = optional(string)
    latest_version = optional(bool)
    license_specification = optional(object({
      license_configuration_arn = string
    }), null)
    maintenance_options = optional(object({
      auto_recovery = string
    }), null)
    metadata_options = optional(object({
      http_endpoint               = string
      http_put_response_hop_limit = number
      http_tokens                 = string
      instance_metadata_tags      = string
    }), null)
    network_interfaces = optional(list(object({
      associate_public_ip_address = bool
      subnet_id                   = string
    })), [])
    placement = optional(object({
      affinity                = optional(string)
      availability_zone       = optional(string)
      group_name              = optional(string)
      host_id                 = optional(string)
      host_resource_group_arn = optional(string)
      spread_domain           = optional(string)
      tenancy                 = optional(string)
      partition_number        = optional(number)
    }), {})
    private_dns_name_options = optional(object({
      enable_resource_name_dns_aaaa_record = optional(bool)
      enable_resource_name_dns_a_record    = optional(bool)
      hostname_type                        = optional(string)
    }), null)

    ram_disk_id = optional(string)

    tag_specifications = optional(object({
      resource_type = optional(string)
      tags          = optional(map(string))
    }), {})
  })
  default = {
    create        = false
    instance_type = "t2.micro"
  }
}

variable "lifecycle_hooks" {
  description = "List of lifecycle hooks for the autoscaling group"
  type = list(object({
    name                    = string
    default_result          = string
    heartbeat_timeout       = number
    lifecycle_transition    = string
    notification_metadata   = string
    notification_target_arn = string
    role_arn                = string
  }))
  default = []
}

variable "placement_group" {
  description = "Configuration for the placement group"
  type = object({
    name            = optional(string, null)
    strategy        = optional(string, "cluster")
    partition_count = optional(number, 2)
    spread_level    = optional(string, "rack")
  })
  default = null
}

variable "project_name" {
  description = "Project name used to find the appropriate AMI for the launch configuration"
  type        = string
}

variable "propagate_tags_at_launch" {
  description = "Specifies whether tags are propagated to the instances in the Auto Scaling group"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "List of security group IDs that will be applied to the autoscaling group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Arbitrary tags that will be applied to all resources created in this module"
  type        = map(string)
  default     = {}
}

variable "vpc_cluster" {
  description = "Boolean flag to indicate if the cluster is within a VPC"
  type        = bool
  default     = true
}
