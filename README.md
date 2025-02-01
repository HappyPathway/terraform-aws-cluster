[![Terraform Validation](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform.yaml)


[![Terraform Doc](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform-doc.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform-doc.yaml)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.84.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.84.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_attachment.autoscaling_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [local.autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_lifecycle_hook.hook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_policy.asg_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_schedule.asg_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_autoscaling_traffic_source_attachment.traffic_source_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_traffic_source_attachment) | resource |
| [aws_launch_configuration.lc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_launch_template.lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_placement_group.pg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [cloudinit_config.cloud_init](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Configuration for the AMI data source | <pre>object({<br>    most_recent      = optional(bool, true)<br>    owners           = optional(list(string), ["self"])<br>    executable_users = optional(list(string), ["self"])<br>    name_regex       = optional(string, null)<br>    filters = optional(list(object({<br>      name   = string<br>      values = list(string)<br>    })), [])<br>  })</pre> | <pre>{<br>  "executable_users": [],<br>  "filters": [],<br>  "most_recent": false,<br>  "name_regex": null,<br>  "owners": []<br>}</pre> | no |
| <a name="input_auto_scaling"></a> [auto\_scaling](#input\_auto\_scaling) | Configuration for the auto scaling group | <pre>object({<br>    min_size                         = number<br>    max_size                         = number<br>    desired_capacity                 = number<br>    subnets                          = list(string)<br>    availability_zones               = optional(list(string), [])<br>    capacity_rebalance               = optional(bool, false)<br>    default_cooldown                 = optional(number, 300)<br>    default_instance_warmup          = optional(number, 300)<br>    health_check_grace_period        = optional(number, 300)<br>    health_check_type                = optional(string, "EC2")<br>    load_balancers                   = optional(list(string), [])<br>    target_group_arns                = optional(list(string), [])<br>    termination_policies             = optional(list(string), [])<br>    suspended_processes              = optional(list(string), [])<br>    metrics_granularity              = optional(string, "1Minute")<br>    enabled_metrics                  = optional(list(string), [])<br>    wait_for_capacity_timeout        = optional(string, "10m")<br>    min_elb_capacity                 = optional(number, 0)<br>    wait_for_elb_capacity            = optional(number, 0)<br>    protect_from_scale_in            = optional(bool, false)<br>    service_linked_role_arn          = optional(string, null)<br>    max_instance_lifetime            = optional(number, 0)<br>    force_delete                     = optional(bool, false)<br>    ignore_failed_scaling_activities = optional(bool, false)<br>    desired_capacity_type            = optional(string, "units")<br>    traffic_source = optional(object({<br>      identifier = string<br>      type       = string<br>    }), null)<br>    instance_maintenance_policy = optional(object({<br>      min_healthy_percentage = number<br>      max_healthy_percentage = number<br>    }), null)<br>    initial_lifecycle_hooks = optional(list(object({<br>      name                    = string<br>      lifecycle_transition    = string<br>      notification_target_arn = string<br>      role_arn                = string<br>      notification_metadata   = optional(string, null)<br>      heartbeat_timeout       = optional(number, 3600)<br>      default_result          = optional(string, "CONTINUE")<br>    })), [])<br>    instance_refresh = optional(object({<br>      strategy = string<br>      triggers = list(string)<br>      preferences = optional(object({<br>        instance_warmup              = optional(number, 300)<br>        min_healthy_percentage       = optional(number, 90)<br>        checkpoint_percentages       = optional(list(number), [])<br>        checkpoint_delay             = optional(number, 3600)<br>        max_healthy_percentage       = optional(number, 100)<br>        skip_matching                = optional(bool, false)<br>        auto_rollback                = optional(bool, false)<br>        scale_in_protected_instances = optional(bool, false)<br>        standby_instances            = optional(bool, false)<br>        alarm_specification = optional(object({<br>          alarms = list(string)<br>        }), null)<br>      }), null)<br>    }), null)<br>    warm_pool = optional(object({<br>      instance_reuse_policy = optional(object({<br>        reuse_on_scale_in = bool<br>      }), null)<br>      max_group_prepared_capacity = optional(number, 0)<br>      min_size                    = optional(number, 0)<br>      pool_state                  = optional(string, "Stopped")<br>    }), null)<br>    mixed_instances_policy = optional(object({<br>      instances_distribution = optional(object({<br>        on_demand_allocation_strategy            = optional(string, "prioritized")<br>        on_demand_base_capacity                  = optional(number, 0)<br>        on_demand_percentage_above_base_capacity = optional(number, 100)<br>        spot_allocation_strategy                 = optional(string, "lowest-price")<br>        spot_instance_pools                      = optional(number, 2)<br>        spot_max_price                           = optional(string, "")<br>      }), null)<br>      launch_template = optional(object({<br>        launch_template_specification = object({<br>          launch_template_id = string<br>          version            = optional(string, "$Latest")<br>        })<br>        override = optional(list(object({<br>          instance_type = string<br>        })), [])<br>      }), null)<br>    }), null)<br>  })</pre> | n/a | yes |
| <a name="input_auto_scaling_policy"></a> [auto\_scaling\_policy](#input\_auto\_scaling\_policy) | Configuration for the auto scaling policy | <pre>object({<br>    name                      = string<br>    scaling_adjustment        = optional(number)<br>    adjustment_type           = optional(string)<br>    cooldown                  = optional(number)<br>    policy_type               = optional(string)<br>    estimated_instance_warmup = optional(number)<br>    metric_aggregation_type   = optional(string)<br>    step_adjustment = optional(list(object({<br>      scaling_adjustment          = number<br>      metric_interval_lower_bound = optional(number)<br>      metric_interval_upper_bound = optional(number)<br>    })))<br>    target_tracking_configuration = optional(object({<br>      predefined_metric_specification = optional(object({<br>        predefined_metric_type = string<br>        resource_label         = optional(string)<br>      }))<br>      customized_metric_specification = optional(object({<br>        metric_dimension = optional(list(object({<br>          name  = string<br>          value = string<br>        })))<br>        metric_name = string<br>        namespace   = string<br>        statistic   = string<br>        unit        = optional(string)<br>        metrics = optional(list(object({<br>          expression = optional(string)<br>          id         = string<br>          label      = optional(string)<br>          metric_stat = optional(object({<br>            metric = object({<br>              dimensions = optional(list(object({<br>                name  = string<br>                value = string<br>              })))<br>              metric_name = string<br>              namespace   = string<br>            })<br>            stat = string<br>            unit = optional(string)<br>          }))<br>          return_data = optional(bool)<br>        })))<br>      }))<br>      target_value     = number<br>      disable_scale_in = optional(bool, false)<br>    }))<br>    predictive_scaling_configuration = optional(object({<br>      max_capacity_breach_behavior = optional(string)<br>      max_capacity_buffer          = optional(number)<br>      metric_specification = object({<br>        target_value = number<br>        customized_capacity_metric_specification = optional(object({<br>          metric_data_queries = list(object({<br>            expression = optional(string)<br>            id         = string<br>            label      = optional(string)<br>            metric_stat = optional(object({<br>              metric = object({<br>                dimensions = optional(list(object({<br>                  name  = string<br>                  value = string<br>                })))<br>                metric_name = string<br>                namespace   = string<br>              })<br>              stat = string<br>              unit = optional(string)<br>            }))<br>            return_data = optional(bool)<br>          }))<br>        }))<br>        customized_load_metric_specification = optional(object({<br>          metric_data_queries = list(object({<br>            expression = optional(string)<br>            id         = string<br>            label      = optional(string)<br>            metric_stat = optional(object({<br>              metric = object({<br>                dimensions = optional(list(object({<br>                  name  = string<br>                  value = string<br>                })))<br>                metric_name = string<br>                namespace   = string<br>              })<br>              stat = string<br>              unit = optional(string)<br>            }))<br>            return_data = optional(bool)<br>          }))<br>        }))<br>        customized_scaling_metric_specification = optional(object({<br>          metric_data_queries = list(object({<br>            expression = optional(string)<br>            id         = string<br>            label      = optional(string)<br>            metric_stat = optional(object({<br>              metric = object({<br>                dimensions = optional(list(object({<br>                  name  = string<br>                  value = string<br>                })))<br>                metric_name = string<br>                namespace   = string<br>              })<br>              stat = string<br>              unit = optional(string)<br>            }))<br>            return_data = optional(bool)<br>          }))<br>        }))<br>        predefined_load_metric_specification = optional(object({<br>          predefined_metric_type = string<br>          resource_label         = string<br>        }))<br>        predefined_metric_pair_specification = optional(object({<br>          predefined_metric_type = string<br>          resource_label         = string<br>        }))<br>        predefined_scaling_metric_specification = optional(object({<br>          predefined_metric_type = string<br>          resource_label         = string<br>        }))<br>      })<br>      mode                   = optional(string)<br>      scheduling_buffer_time = optional(number)<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_autoscaling_attachment"></a> [autoscaling\_attachment](#input\_autoscaling\_attachment) | Configuration for the autoscaling attachment | <pre>object({<br>    elb                 = string<br>    lb_target_group_arn = string<br>  })</pre> | `null` | no |
| <a name="input_autoscaling_schedule"></a> [autoscaling\_schedule](#input\_autoscaling\_schedule) | List of autoscaling schedules | <pre>list(object({<br>    scheduled_action_name = string<br>    start_time            = optional(string)<br>    end_time              = optional(string)<br>    recurrence            = optional(string)<br>    min_size              = optional(number)<br>    max_size              = optional(number)<br>    desired_capacity      = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_autoscaling_traffic_source_attachment"></a> [autoscaling\_traffic\_source\_attachment](#input\_autoscaling\_traffic\_source\_attachment) | Configuration for the autoscaling traffic source attachment | <pre>object({<br>    identifier = string<br>    type       = string<br>  })</pre> | `null` | no |
| <a name="input_cloud_init_config"></a> [cloud\_init\_config](#input\_cloud\_init\_config) | Cloud-init configuration that will be appended to user-data for the launch configuration | <pre>list(object({<br>    path    = string<br>    content = string<br>  }))</pre> | `[]` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired capacity of the autoscaling group | `number` | `2` | no |
| <a name="input_ebs_block_devices"></a> [ebs\_block\_devices](#input\_ebs\_block\_devices) | n/a | <pre>list(object({<br>    device_name           = string<br>    snapshot_id           = optional(string, null)<br>    iops                  = optional(number, 0)<br>    throughput            = optional(number, 0)<br>    delete_on_termination = optional(bool, true)<br>    encrypted             = optional(bool, false)<br>    no_device             = optional(bool, false)<br>    volume_size           = optional(number, 8)<br>    volume_type           = optional(string, "gp2")<br>  }))</pre> | `[]` | no |
| <a name="input_ephemeral_block_devices"></a> [ephemeral\_block\_devices](#input\_ephemeral\_block\_devices) | n/a | <pre>list(object({<br>    device_name  = string<br>    virtual_name = string<br>    no_device    = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_file_list"></a> [file\_list](#input\_file\_list) | List of files to be included in the configuration | <pre>list(object({<br>    filename     = string<br>    content_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type that will be used for the launch configuration | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name that will be used for the launch configuration | `string` | n/a | yes |
| <a name="input_launch_configuration"></a> [launch\_configuration](#input\_launch\_configuration) | Configuration for the launch configuration | <pre>object({<br>    iam_instance_profile        = optional(string, null)<br>    associate_public_ip_address = optional(bool, false)<br>    placement_tenancy           = optional(string, "default")<br>    key_name                    = optional(string, null)<br>    enable_monitoring           = optional(bool, false)<br>    ebs_optimized               = optional(bool, false)<br>    metadata_options = optional(object({<br>      http_tokens                 = optional(string, "optional")<br>      http_put_response_hop_limit = optional(number, 1)<br>      http_endpoint               = optional(string, "enabled")<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | Configuration for the launch template | <pre>object({<br>    block_device_mappings = list(object({<br>      device_name = string<br>      ebs = object({<br>        volume_size = number<br>        volume_type = string<br>      })<br>    }))<br>    capacity_reservation_specification = list(object({<br>      capacity_reservation_preference = string<br>    }))<br>    cpu_options = list(object({<br>      core_count       = number<br>      threads_per_core = number<br>    }))<br>    credit_specification = list(object({<br>      cpu_credits = string<br>    }))<br>    elastic_gpu_specifications = list(object({<br>      type = string<br>    }))<br>    elastic_inference_accelerator = list(object({<br>      type = string<br>    }))<br>    enclave_options = list(object({<br>      enabled = bool<br>    }))<br>    hibernation_options = list(object({<br>      configured = bool<br>    }))<br>    iam_instance_profile = list(object({<br>      name = string<br>    }))<br>    instance_market_options = list(object({<br>      market_type = string<br>      spot_options = object({<br>        block_duration_minutes         = number<br>        instance_interruption_behavior = string<br>        max_price                      = string<br>        spot_instance_type             = string<br>        valid_until                    = string<br>      })<br>    }))<br>    instance_requirements = list(object({<br>      vcpu_count = object({<br>        min = number<br>        max = number<br>      })<br>      memory_mib = object({<br>        min = number<br>        max = number<br>      })<br>    }))<br><br>    kernel_id = optional(string)<br>    key_name  = optional(string)<br><br>    license_specification = list(object({<br>      license_configuration_arn = string<br>    }))<br>    maintenance_options = list(object({<br>      auto_recovery = string<br>    }))<br>    metadata_options = list(object({<br>      http_endpoint               = string<br>      http_put_response_hop_limit = number<br>      http_tokens                 = string<br>      instance_metadata_tags      = string<br>    }))<br>    network_interfaces = list(object({<br>      associate_public_ip_address = bool<br>      subnet_id                   = string<br>    }))<br>    placement = list(object({<br>      availability_zone = string<br>    }))<br>    private_dns_name_options = list(object({<br>      enable_resource_name_dns_aaaa_record = bool<br>      enable_resource_name_dns_a_record    = bool<br>      hostname_type                        = string<br>    }))<br><br>    ram_disk_id = optional(string)<br><br>    tag_specifications = list(object({<br>      resource_type = string<br>      tags          = map(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_lifecycle_hooks"></a> [lifecycle\_hooks](#input\_lifecycle\_hooks) | n/a | <pre>list(object({<br>    name                    = string<br>    default_result          = string<br>    heartbeat_timeout       = number<br>    lifecycle_transition    = string<br>    notification_metadata   = string<br>    notification_target_arn = string<br>    role_arn                = string<br>  }))</pre> | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum size of the autoscaling group | `number` | `3` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum size of the autoscaling group | `number` | `1` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | Configuration for the placement group | <pre>object({<br>    name            = optional(string, null)<br>    strategy        = optional(string, "cluster")<br>    partition_count = optional(number, 2)<br>    spread_level    = optional(string, "rack")<br>  })</pre> | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used to find the appropriate AMI for the launch configuration | `string` | n/a | yes |
| <a name="input_propagate_tags_at_launch"></a> [propagate\_tags\_at\_launch](#input\_propagate\_tags\_at\_launch) | Specifies whether tags are propagated to the instances in the Auto Scaling group | `bool` | `true` | no |
| <a name="input_root_volume"></a> [root\_volume](#input\_root\_volume) | n/a | <pre>object({<br>    iops                  = optional(number, 0)<br>    throughput            = optional(number, 0)<br>    delete_on_termination = optional(bool, true)<br>    encrypted             = optional(bool, false)<br>    volume_size           = optional(number, 8)<br>    volume_type           = optional(string, "gp2")<br>  })</pre> | `{}` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs that will be applied to the autoscaling group | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets that the autoscaling group will be deployed to | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Arbitrary tags that will be applied to all resources created in this module | `map(string)` | n/a | yes |
| <a name="input_volume_mappings"></a> [volume\_mappings](#input\_volume\_mappings) | List of volume mappings that will be applied to the launch configuration | `list(map(string))` | n/a | yes |
| <a name="input_vpc_cluster"></a> [vpc\_cluster](#input\_vpc\_cluster) | n/a | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami"></a> [ami](#output\_ami) | n/a |
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | n/a |
| <a name="output_cloud_init"></a> [cloud\_init](#output\_cloud\_init) | n/a |
| <a name="output_launch_configuration"></a> [launch\_configuration](#output\_launch\_configuration) | n/a |
 <!-- END_TF_DOCS -->

## Examples

### Basic Auto Scaling Group

This example demonstrates a basic auto scaling group setup with minimal configuration.

```hcl
module "basic_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
}
```

### Auto Scaling with Launch Template

This example shows how to configure an auto scaling group using a launch template.

```hcl
module "autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
}
```

### Auto Scaling with Mixed Instances Policy

This example provides an auto scaling group with a mixed instances policy.

```hcl
module "mixed_instances_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
    mixed_instances_policy = {
      instances_distribution = {
        on_demand_allocation_strategy            = "prioritized"
        on_demand_base_capacity                  = 1
        on_demand_percentage_above_base_capacity = 50
        spot_allocation_strategy                 = "lowest-price"
        spot_instance_pools                      = 2
      }
      launch_template = {
        launch_template_specification = {
          launch_template_id = aws_launch_template.example.id
          version            = "$Latest"
        }
        override = [
          {
            instance_type = "t3.micro"
          }
        ]
      }
    }
  }
}
```

### Auto Scaling with Lifecycle Hooks

This example illustrates the use of lifecycle hooks in an auto scaling group.

```hcl
module "lifecycle_hooks_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
    initial_lifecycle_hooks = [
      {
        name                    = "ExampleHook"
        lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
        notification_target_arn = "arn:aws:sns:us-east-1:123456789012:ExampleTopic"
        role_arn                = "arn:aws:iam::123456789012:role/ExampleRole"
        notification_metadata   = jsonencode({ "key" = "value" })
        heartbeat_timeout       = 300
        default_result          = "CONTINUE"
      }
    ]
  }
}
```

### Auto Scaling with Scheduled Actions

This example demonstrates how to set up scheduled actions for an auto scaling group.

```hcl
module "scheduled_actions_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
  }
  autoscaling_schedule = [
    {
      scheduled_action_name = "ScaleUp"
      start_time            = "2023-01-01T00:00:00Z"
      min_size              = 2
      max_size              = 4
      desired_capacity      = 3
    },
    {
      scheduled_action_name = "ScaleDown"
      start_time            = "2023-01-01T12:00:00Z"
      min_size              = 1
      max_size              = 2
      desired_capacity      = 1
    }
  ]
}
```

### Auto Scaling with Target Tracking Policy

This example shows how to configure a target tracking scaling policy for an auto scaling group.

```hcl
module "target_tracking_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
  }
  auto_scaling_policy = {
    name                      = "TargetTrackingPolicy"
    policy_type               = "TargetTrackingScaling"
    estimated_instance_warmup = 300
    target_tracking_configuration = {
      predefined_metric_specification = {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value     = 50.0
      disable_scale_in = false
    }
  }
}
```

### Auto Scaling with Step Scaling Policy

This example provides a step scaling policy for an auto scaling group.

```hcl
module "step_scaling_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
  }
  auto_scaling_policy = {
    name            = "StepScalingPolicy"
    policy_type     = "StepScaling"
    adjustment_type = "ChangeInCapacity"
    cooldown        = 300
    step_adjustment = [
      {
        scaling_adjustment          = 1
        metric_interval_lower_bound = 0
        metric_interval_upper_bound = 10
      },
      {
        scaling_adjustment          = 2
        metric_interval_lower_bound = 10
        metric_interval_upper_bound = 20
      }
    ]
  }
}
```

### Auto Scaling with Predictive Scaling Policy

This example illustrates the use of predictive scaling policies in an auto scaling group.

```hcl
module "predictive_scaling_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
  }
  auto_scaling_policy = {
    name                      = "PredictiveScalingPolicy"
    policy_type               = "PredictiveScaling"
    estimated_instance_warmup = 300
    predictive_scaling_configuration = {
      metric_specification = {
        target_value = 50.0
        predefined_load_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        predefined_scaling_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
      }
      mode                   = "ForecastAndScale"
      scheduling_buffer_time = 300
    }
  }
}
```

### Auto Scaling with Warm Pools

This example demonstrates the configuration of warm pools in an auto scaling group.

```hcl
module "warm_pools_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
    warm_pool = {
      instance_reuse_policy = {
        reuse_on_scale_in = true
      }
      max_group_prepared_capacity = 2
      min_size                    = 1
      pool_state                  = "Stopped"
    }
  }
}
```

### Auto Scaling with Traffic Sources

This example shows how to attach traffic sources to an auto scaling group.

```hcl
module "traffic_sources_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets = [
      "subnet-0038fa2a217039c17",
      "subnet-061980a4fef9ebf6a",
      "subnet-015d2308cbd1329d5"
    ]
  }
  autoscaling_traffic_source_attachment = {
    identifier = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/ExampleTargetGroup/1234567890123456"
    type       = "elb"
  }
}
```
