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
  description = "Configuration for the auto scaling group"
  type = object({
    create                           = bool
    min_size                         = number
    max_size                         = number
    desired_capacity                 = number
    subnets                          = optional(list(string), null)
    availability_zones               = optional(list(string), null)
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
      triggers = list(string)
      preferences = optional(object({
        instance_warmup              = optional(number, 300)
        min_healthy_percentage       = optional(number, 90)
        checkpoint_percentages       = optional(list(number), [])
        checkpoint_delay             = optional(number, 3600)
        max_healthy_percentage       = optional(number, 100)
        skip_matching                = optional(bool, false)
        auto_rollback                = optional(bool, false)
        scale_in_protected_instances = optional(bool, false)
        standby_instances            = optional(bool, false)
        alarm_specification = optional(object({
          alarms = list(string)
        }), null)
      }), null)
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
}

variable "auto_scaling_policy" {
  description = "Configuration for the auto scaling policy"
  type = object({
    name                      = string
    scaling_adjustment        = optional(number)
    adjustment_type           = optional(string)
    cooldown                  = optional(number)
    policy_type               = optional(string)
    estimated_instance_warmup = optional(number)
    metric_aggregation_type   = optional(string)
    step_adjustment = optional(list(object({
      scaling_adjustment          = number
      metric_interval_lower_bound = optional(number)
      metric_interval_upper_bound = optional(number)
    })))
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
        statistic   = string
        unit        = optional(string)
        metrics = optional(list(object({
          expression = optional(string)
          id         = string
          label      = optional(string)
          metric_stat = optional(object({
            metric = object({
              dimensions = optional(list(object({
                name  = string
                value = string
              })))
              metric_name = string
              namespace   = string
            })
            stat = string
            unit = optional(string)
          }))
          return_data = optional(bool)
        })))
      }))
      target_value     = number
      disable_scale_in = optional(bool, false)
    }))
    predictive_scaling_configuration = optional(object({
      max_capacity_breach_behavior = optional(string)
      max_capacity_buffer          = optional(number)
      metric_specification = object({
        target_value = number
        customized_capacity_metric_specification = optional(object({
          metric_data_queries = list(object({
            expression = optional(string)
            id         = string
            label      = optional(string)
            metric_stat = optional(object({
              metric = object({
                dimensions = optional(list(object({
                  name  = string
                  value = string
                })))
                metric_name = string
                namespace   = string
              })
              stat = string
              unit = optional(string)
            }))
            return_data = optional(bool)
          }))
        }))
        customized_load_metric_specification = optional(object({
          metric_data_queries = list(object({
            expression = optional(string)
            id         = string
            label      = optional(string)
            metric_stat = optional(object({
              metric = object({
                dimensions = optional(list(object({
                  name  = string
                  value = string
                })))
                metric_name = string
                namespace   = string
              })
              stat = string
              unit = optional(string)
            }))
            return_data = optional(bool)
          }))
        }))
        customized_scaling_metric_specification = optional(object({
          metric_data_queries = list(object({
            expression = optional(string)
            id         = string
            label      = optional(string)
            metric_stat = optional(object({
              metric = object({
                dimensions = optional(list(object({
                  name  = string
                  value = string
                })))
                metric_name = string
                namespace   = string
              })
              stat = string
              unit = optional(string)
            }))
            return_data = optional(bool)
          }))
        }))
        predefined_load_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = string
        }))
        predefined_metric_pair_specification = optional(object({
          predefined_metric_type = string
          resource_label         = string
        }))
        predefined_scaling_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = string
        }))
      })
      mode                   = optional(string)
      scheduling_buffer_time = optional(number)
    }))
  })
  default = null
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
    use_launch_template = optional(bool, false)
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
