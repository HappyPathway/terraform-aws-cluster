

[![Terraform Validation](https://github.com/HappyPathway/terraform-aws-morpheus-cluster/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-morpheus-cluster/actions/workflows/terraform.yaml)

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
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_configuration.lc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_placement_group.pg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [cloudinit_config.cloud_init](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Configuration for the AMI data source | <pre>object({<br>    most_recent      = optional(bool, true)<br>    owners           = optional(list(string), ["self"])<br>    executable_users = optional(list(string), ["self"])<br>    name_regex       = optional(string, null)<br>    filters = optional(list(object({<br>      name   = string<br>      values = list(string)<br>    })), [])<br>  })</pre> | <pre>{<br>  "executable_users": [],<br>  "filters": [],<br>  "most_recent": false,<br>  "name_regex": null,<br>  "owners": []<br>}</pre> | no |
| <a name="input_auto_scaling"></a> [auto\_scaling](#input\_auto\_scaling) | Configuration for the Auto Scaling Group | <pre>object({<br>    project_name                     = string<br>    min_size                         = number<br>    max_size                         = number<br>    desired_capacity                 = number<br>    subnets                          = list(string)<br>    availability_zones               = optional(list(string), [])<br>    capacity_rebalance               = optional(bool, false)<br>    default_cooldown                 = optional(number, 300)<br>    default_instance_warmup          = optional(number, 300)<br>    health_check_grace_period        = optional(number, 300)<br>    health_check_type                = optional(string, "EC2")<br>    load_balancers                   = optional(list(string), [])<br>    target_group_arns                = optional(list(string), [])<br>    termination_policies             = optional(list(string), [])<br>    suspended_processes              = optional(list(string), [])<br>    metrics_granularity              = optional(string, "1Minute")<br>    enabled_metrics                  = optional(list(string), [])<br>    wait_for_capacity_timeout        = optional(string, "10m")<br>    min_elb_capacity                 = optional(number, 0)<br>    wait_for_elb_capacity            = optional(number, 0)<br>    protect_from_scale_in            = optional(bool, false)<br>    service_linked_role_arn          = optional(string, null)<br>    max_instance_lifetime            = optional(number, 0)<br>    force_delete                     = optional(bool, false)<br>    ignore_failed_scaling_activities = optional(bool, false)<br>    desired_capacity_type            = optional(string, "units")<br>    traffic_source = optional(object({<br>      identifier = string<br>      type       = string<br>    }), null)<br>    instance_maintenance_policy = optional(object({<br>      min_healthy_percentage = number<br>      max_healthy_percentage = number<br>    }), null)<br>    initial_lifecycle_hooks = optional(list(object({<br>      name                    = string<br>      lifecycle_transition    = string<br>      notification_target_arn = string<br>      role_arn                = string<br>      notification_metadata   = optional(string, null)<br>      heartbeat_timeout       = optional(number, 3600)<br>      default_result          = optional(string, "CONTINUE")<br>    })), [])<br>    instance_refresh = optional(object({<br>      strategy = string<br>      triggers = optional(list(string), [])<br>      preferences = optional(object({<br>        instance_warmup              = optional(number, 300)<br>        min_healthy_percentage       = optional(number, 90)<br>        checkpoint_percentages       = optional(list(number), [])<br>        checkpoint_delay             = optional(number, 3600)<br>        max_healthy_percentage       = optional(number, 100)<br>        skip_matching                = optional(bool, false)<br>        auto_rollback                = optional(bool, false)<br>        scale_in_protected_instances = optional(string, "Ignore")<br>        standby_instances            = optional(string, "Ignore")<br>        alarm_specification = optional(object({<br>          alarms = list(string)<br>        }), null)<br>      }), null)<br>    }), null)<br>    warm_pool = optional(object({<br>      instance_reuse_policy = optional(object({<br>        reuse_on_scale_in = optional(bool, false)<br>      }), null)<br>      max_group_prepared_capacity = optional(number, 0)<br>      min_size                    = optional(number, 0)<br>      pool_state                  = optional(string, "Stopped")<br>    }), null)<br>  })</pre> | n/a | yes |
| <a name="input_cloud_init_config"></a> [cloud\_init\_config](#input\_cloud\_init\_config) | Cloud-init configuration that will be appended to user-data for the launch configuration | <pre>list(object({<br>    path    = string<br>    content = string<br>  }))</pre> | `[]` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired capacity of the autoscaling group | `number` | `2` | no |
| <a name="input_ebs_block_devices"></a> [ebs\_block\_devices](#input\_ebs\_block\_devices) | n/a | <pre>list(object({<br>    device_name           = string<br>    snapshot_id           = optional(string, null)<br>    iops                  = optional(number, 0)<br>    throughput            = optional(number, 0)<br>    delete_on_termination = optional(bool, true)<br>    encrypted             = optional(bool, false)<br>    no_device             = optional(bool, false)<br>    volume_size           = optional(number, 8)<br>    volume_type           = optional(string, "gp2")<br>  }))</pre> | `[]` | no |
| <a name="input_ephemeral_block_devices"></a> [ephemeral\_block\_devices](#input\_ephemeral\_block\_devices) | n/a | <pre>list(object({<br>    device_name  = string<br>    virtual_name = string<br>    no_device    = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_file_list"></a> [file\_list](#input\_file\_list) | List of files to be included in the configuration | <pre>list(object({<br>    filename     = string<br>    content_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type that will be used for the launch configuration | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name that will be used for the launch configuration | `string` | n/a | yes |
| <a name="input_launch_configuration"></a> [launch\_configuration](#input\_launch\_configuration) | Configuration for the launch configuration | <pre>object({<br>    project_name                = string<br>    iam_instance_profile        = optional(string, null)<br>    instance_type               = string<br>    associate_public_ip_address = optional(bool, false)<br>    placement_tenancy           = optional(string, "default")<br>    key_name                    = optional(string, null)<br>    security_group_ids          = optional(list(string), [])<br>    enable_monitoring           = optional(bool, false)<br>    ebs_optimized               = optional(bool, false)<br>    metadata_options = optional(object({<br>      http_tokens                 = optional(string, "optional")<br>      http_put_response_hop_limit = optional(number, 1)<br>      http_endpoint               = optional(string, "enabled")<br>    }), {})<br>  })</pre> | <pre>{<br>  "instance_type": "t2.micro",<br>  "project_name": "my-project"<br>}</pre> | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum size of the autoscaling group | `number` | `3` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum size of the autoscaling group | `number` | `1` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | Configuration for the placement group | <pre>object({<br>    name            = optional(string, null)<br>    strategy        = optional(string, "cluster")<br>    tags            = optional(map(string), {})<br>    partition_count = optional(number, 2)<br>    spread_level    = optional(string, "rack")<br>  })</pre> | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used to find the appropriate AMI for the launch configuration | `string` | n/a | yes |
| <a name="input_propagate_tags_at_launch"></a> [propagate\_tags\_at\_launch](#input\_propagate\_tags\_at\_launch) | Specifies whether tags are propagated to the instances in the Auto Scaling group | `bool` | `true` | no |
| <a name="input_root_volume"></a> [root\_volume](#input\_root\_volume) | n/a | <pre>object({<br>    iops                  = optional(number, 0)<br>    throughput            = optional(number, 0)<br>    delete_on_termination = optional(bool, true)<br>    encrypted             = optional(bool, false)<br>    volume_size           = optional(number, 8)<br>    volume_type           = optional(string, "gp2")<br>  })</pre> | `{}` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs that will be applied to the autoscaling group | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets that the autoscaling group will be deployed to | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Arbitrary tags that will be applied to all resources created in this module | `map(string)` | n/a | yes |
| <a name="input_volume_mappings"></a> [volume\_mappings](#input\_volume\_mappings) | List of volume mappings that will be applied to the launch configuration | `list(map(string))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami"></a> [ami](#output\_ami) | n/a |
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | n/a |
| <a name="output_cloud_init"></a> [cloud\_init](#output\_cloud\_init) | n/a |
| <a name="output_launch_configuration"></a> [launch\_configuration](#output\_launch\_configuration) | n/a |
<!-- END_TF_DOCS -->