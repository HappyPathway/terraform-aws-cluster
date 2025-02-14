# AWS Auto Scaling Group Terraform Module

[![Terraform Validation](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform.yaml)
[![Terraform Doc](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform-doc.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-cluster/actions/workflows/terraform-doc.yaml)

## Default Configuration Improvements

This module now includes optimized defaults for Auto Scaling Groups:

### Health Check Configuration
- `health_check_type`: Default set to "ELB" for better reliability when used with load balancers
- `health_check_grace_period`: Set to 300 seconds (5 minutes) to allow sufficient time for instance initialization

### Capacity Management
- `capacity_rebalance`: Enabled by default for better availability across AZs
- `default_cooldown`: Set to 300 seconds to prevent rapid scaling changes
- `default_instance_warmup`: Set to 300 seconds for proper instance initialization

### Monitoring and Metrics
- `metrics_granularity`: Set to "1Minute" for detailed monitoring
- Default enabled metrics include:
  - GroupMinSize
  - GroupMaxSize
  - GroupDesiredCapacity
  - GroupInServiceInstances
  - GroupPendingInstances
  - GroupStandbyInstances
  - GroupTerminatingInstances
  - GroupTotalInstances

### Input Validations
The module now includes strict validations:
- Ensures desired_capacity is between min_size and max_size
- Validates max_size is greater than 0 when ASG is enabled
- Requires either subnets or availability_zones to be specified
- Validates health_check_type is either 'EC2' or 'ELB'

## Instance Refresh Optimization

The module now includes improved instance refresh defaults for safer rolling updates:

### Default Instance Refresh Settings
- `triggers`: Automatically set to track both tags and launch template changes
- `min_healthy_percentage`: Set to 90% to maintain high availability during updates
- `checkpoint_percentages`: Pre-configured checkpoints at 20%, 40%, 60%, 80%, and 100%
- `auto_rollback`: Enabled by default to prevent failed deployments
- `scale_in_protected_instances`: Set to "WAIT" to handle protected instances safely
- `standby_instances`: Set to "TERMINATE" for clean instance replacement

### Safety Mechanisms
- Validates instance refresh strategy is "Rolling"
- Ensures min_healthy_percentage is between 0-100
- Prevents accidental detachment of load balancers during updates
- Requires minimum capacity > 0 for service availability
- Automatic rollback on failed deployments

### Best Practices
- Use the default checkpoints for gradual rollouts
- Keep min_healthy_percentage high for production workloads
- Let auto_rollback protect against failed deployments
- Configure alarm_specification for additional safety

## Scaling Policy Optimizations

The module now includes improved defaults and validations for scaling policies:

### Target Tracking Scaling (Default)
- Default policy type set to `TargetTrackingScaling` for easier maintenance
- Pre-configured metric aggregation as "Average"
- Built-in protection against scale-in by default
- Standard instance warmup period of 300 seconds

### Step Scaling Enhancements
- Automatic default lower bound of 0 for metric intervals
- Preconfigured cooldown period of 300 seconds
- Metric aggregation defaulted to "Average"

### Predictive Scaling Features
- Default mode set to "ForecastAndScale"
- Scheduling buffer time of 300 seconds
- Max capacity breach behavior set to "HonorMaxCapacity"
- Built-in capacity buffer management

### Policy Type Validation
- Enforces valid policy types: SimpleScaling, StepScaling, TargetTrackingScaling, PredictiveScaling
- Validates target values are positive numbers
- Ensures cooldown and warmup periods are non-negative
- Conditional parameter validation based on policy type

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.84.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.87.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_attachment.autoscaling_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_lifecycle_hook.hook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_policy.asg_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_schedule.asg_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_autoscaling_traffic_source_attachment.traffic_source_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_traffic_source_attachment) | resource |
| [aws_launch_template.lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_placement_group.pg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group) | data source |
| [aws_launch_template.lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/launch_template) | data source |
| [cloudinit_config.cloud_init](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Configuration for the AMI data source | <pre>object({<br>    most_recent      = optional(bool, true)<br>    owners           = optional(list(string), null)<br>    executable_users = optional(list(string), null)<br>    name_regex       = optional(string, null)<br>    filters = optional(list(object({<br>      name   = string<br>      values = list(string)<br>    })), [])<br>  })</pre> | n/a | yes |
| <a name="input_auto_scaling"></a> [auto\_scaling](#input\_auto\_scaling) | Configuration for the auto scaling group. Requires min\_size, max\_size, and desired\_capacity to be set when create is true. | <pre>object({<br>    create                           = bool<br>    min_size                         = number<br>    max_size                         = number<br>    desired_capacity                 = number<br>    subnets                          = optional(list(string), null)<br>    availability_zones               = optional(list(string), null)<br>    capacity_rebalance               = optional(bool, true)  # Changed default to true for better availability<br>    default_cooldown                 = optional(number, 300)<br>    default_instance_warmup          = optional(number, 300)<br>    health_check_grace_period        = optional(number, 300)<br>    health_check_type                = optional(string, "ELB") # Changed default to ELB for better reliability<br>    load_balancers                   = optional(list(string), [])<br>    target_group_arns                = optional(list(string), [])<br>    termination_policies             = optional(list(string), ["Default"]) # Added default termination policy<br>    suspended_processes              = optional(list(string), [])<br>    metrics_granularity              = optional(string, "1Minute")<br>    enabled_metrics                  = optional(list(string), [<br>      "GroupMinSize",<br>      "GroupMaxSize",<br>      "GroupDesiredCapacity",<br>      "GroupInServiceInstances",<br>      "GroupPendingInstances",<br>      "GroupStandbyInstances",<br>      "GroupTerminatingInstances",<br>      "GroupTotalInstances"<br>    ]) # Added default metrics for better monitoring<br>    wait_for_capacity_timeout        = optional(string, "10m")<br>    min_elb_capacity                 = optional(number, null)<br>    wait_for_elb_capacity            = optional(number, null)<br>    protect_from_scale_in            = optional(bool, false)<br>    service_linked_role_arn          = optional(string, null)<br>    max_instance_lifetime            = optional(number, 0)<br>    force_delete                     = optional(bool, false)<br>    ignore_failed_scaling_activities = optional(bool, false)<br>    desired_capacity_type            = optional(string, "units")<br>    traffic_source = optional(object({<br>      identifier = string<br>      type       = string<br>    }), null)<br>    instance_maintenance_policy = optional(object({<br>      min_healthy_percentage = number<br>      max_healthy_percentage = number<br>    }), null)<br>    initial_lifecycle_hooks = optional(list(object({<br>      name                    = string<br>      lifecycle_transition    = string<br>      notification_target_arn = string<br>      role_arn                = string<br>      notification_metadata   = optional(string, null)<br>      heartbeat_timeout       = optional(number, 3600)<br>      default_result          = optional(string, "CONTINUE")<br>    })), [])<br>    instance_refresh = optional(object({<br>      strategy = string<br>      triggers = optional(list(string), ["tag", "launch_template"])  # Added default triggers<br>      preferences = optional(object({<br>        instance_warmup              = optional(number, 300)<br>        min_healthy_percentage       = optional(number, 90)<br>        checkpoint_percentages       = optional(list(number), [20, 40, 60, 80, 100])  # Added default checkpoints<br>        checkpoint_delay             = optional(number, 300)<br>        max_healthy_percentage       = optional(number, 100)<br>        skip_matching                = optional(bool, false)<br>        auto_rollback                = optional(bool, true)  # Changed default to true<br>        scale_in_protected_instances = optional(string, "WAIT")  # Added default behavior<br>        standby_instances            = optional(string, "TERMINATE")  # Added default behavior<br>        alarm_specification = optional(object({<br>          alarms = list(string)<br>        }), null)<br>      }), null)<br>    }), null)<br>    warm_pool = optional(object({<br>      instance_reuse_policy = optional(object({<br>        reuse_on_scale_in = bool<br>      }), null)<br>      max_group_prepared_capacity = optional(number, 0)<br>      min_size                    = optional(number, 0)<br>      pool_state                  = optional(string, "Stopped")<br>    }), null)<br>    mixed_instances_policy = optional(object({<br>      instances_distribution = optional(object({<br>        on_demand_allocation_strategy            = optional(string, "prioritized")<br>        on_demand_base_capacity                  = optional(number, 0)<br>        on_demand_percentage_above_base_capacity = optional(number, 100)<br>        spot_allocation_strategy                 = optional(string, "lowest-price")<br>        spot_instance_pools                      = optional(number, 2)<br>        spot_max_price                           = optional(string, "")<br>      }), null)<br>      launch_template = optional(object({<br>        launch_template_specification = object({<br>          launch_template_id = string<br>          version            = optional(string, "$Latest")<br>        })<br>        override = optional(list(object({<br>          instance_type = string<br>        })), [])<br>      }), null)<br>    }), null)<br>  })</pre> | <pre>{<br>  "create": false,<br>  "desired_capacity": 0,<br>  "health_check_type": "ELB",<br>  "instance_refresh": null,<br>  "max_size": 0,<br>  "min_size": 0,<br>  "subnets": []<br>}</pre> | no |
| <a name="input_auto_scaling_policy"></a> [auto\_scaling\_policy](#input\_auto\_scaling\_policy) | Configuration for the auto scaling policy. Supports target tracking, step scaling, and predictive scaling. | <pre>object({<br>    name                      = string<br>    policy_type               = optional(string, "TargetTrackingScaling")<br>    scaling_adjustment        = optional(number)<br>    adjustment_type           = optional(string, "ChangeInCapacity")<br>    cooldown                  = optional(number, 300)<br>    estimated_instance_warmup = optional(number, 300)<br>    metric_aggregation_type   = optional(string, "Average")<br>    <br>    # Enhanced step scaling configuration<br>    step_adjustment = optional(list(object({<br>      scaling_adjustment          = number<br>      metric_interval_lower_bound = optional(number, 0)<br>      metric_interval_upper_bound = optional(number)<br>    })))<br>    <br>    # Improved target tracking configuration<br>    target_tracking_configuration = optional(object({<br>      predefined_metric_specification = optional(object({<br>        predefined_metric_type = string<br>        resource_label         = optional(string)<br>      }))<br>      customized_metric_specification = optional(object({<br>        metric_dimension = optional(list(object({<br>          name  = string<br>          value = string<br>        })))<br>        metric_name = string<br>        namespace   = string<br>        statistic   = optional(string, "Average")<br>        unit        = optional(string)<br>      }))<br>      target_value     = number<br>      disable_scale_in = optional(bool, false)<br>    }))<br>    # Enhanced predictive scaling configuration<br>    predictive_scaling_configuration = optional(object({<br>      max_capacity_breach_behavior = optional(string, "HonorMaxCapacity")<br>      max_capacity_buffer         = optional(number, 0)<br>      scheduling_buffer_time      = optional(number, 300)<br>      mode                        = optional(string, "ForecastAndScale")<br>      metric_specification = object({<br>        target_value = number<br>        predefined_load_metric_specification = optional(object({<br>          predefined_metric_type = string<br>          resource_label         = string<br>        }))<br>        predefined_scaling_metric_specification = optional(object({<br>          predefined_metric_type = string<br>          resource_label         = string<br>        }))<br>      })<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_autoscaling_attachment"></a> [autoscaling\_attachment](#input\_autoscaling\_attachment) | Configuration for the autoscaling attachment | <pre>object({<br>    elb                 = string<br>    lb_target_group_arn = string<br>  })</pre> | `null` | no |
| <a name="input_autoscaling_schedule"></a> [autoscaling\_schedule](#input\_autoscaling\_schedule) | List of autoscaling schedules | <pre>list(object({<br>    scheduled_action_name = string<br>    start_time            = optional(string)<br>    end_time              = optional(string)<br>    recurrence            = optional(string)<br>    min_size              = optional(number)<br>    max_size              = optional(number)<br>    desired_capacity      = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_autoscaling_traffic_source_attachment"></a> [autoscaling\_traffic\_source\_attachment](#input\_autoscaling\_traffic\_source\_attachment) | Configuration for the autoscaling traffic source attachment | <pre>object({<br>    identifier = string<br>    type       = string<br>  })</pre> | `null` | no |
| <a name="input_cloud_init_config"></a> [cloud\_init\_config](#input\_cloud\_init\_config) | Cloud-init configuration that will be appended to user-data for the launch configuration | <pre>list(object({<br>    path    = string<br>    content = string<br>  }))</pre> | `[]` | no |
| <a name="input_file_list"></a> [file\_list](#input\_file\_list) | List of files to be included in the configuration | <pre>list(object({<br>    filename     = string<br>    content_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type that will be used for the launch configuration | `string` | n/a | yes |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | Configuration for the launch template | <pre>object({<br>    create              = optional(bool, false)<br>    use_launch_template = optional(bool, true)<br>    name                = optional(string, null)<br>    block_device_mappings = optional(list(object({<br>      device_name = string<br>      ebs = object({<br>        volume_size = number<br>        volume_type = string<br>      })<br>    })), [])<br>    capacity_reservation_specification = optional(object({<br>      capacity_reservation_preference = string<br>    }), null)<br>    cpu_options = optional(object({<br>      core_count       = number<br>      threads_per_core = number<br>    }), null)<br>    credit_specification = optional(object({<br>      cpu_credits = string<br>    }), null)<br>    disable_api_stop        = optional(bool, false)<br>    disable_api_termination = optional(bool, false)<br>    ebs_optimized           = optional(bool, false)<br>    elastic_gpu_specifications = optional(object({<br>      type = string<br>    }), null)<br>    elastic_inference_accelerator = optional(object({<br>      type = string<br>    }), null)<br>    enclave_options = optional(object({<br>      enabled = bool<br>    }), null)<br>    hibernation_options = optional(object({<br>      configured = bool<br>    }), null)<br>    iam_instance_profile = optional(object({<br>      name = string<br>    }), null)<br>    instance_market_options = optional(object({<br>      market_type = string<br>      spot_options = object({<br>        block_duration_minutes         = number<br>        instance_interruption_behavior = string<br>        max_price                      = string<br>        spot_instance_type             = string<br>        valid_until                    = string<br>      })<br>    }), null)<br>    instance_requirements = optional(object({<br>      vcpu_count = optional(object({<br>        min = number<br>        max = number<br>      }), null)<br>      memory_mib = optional(object({<br>        min = number<br>        max = number<br>      }), null)<br>    }), null)<br><br>    kernel_id      = optional(string)<br>    key_name       = optional(string)<br>    latest_version = optional(bool)<br>    license_specification = optional(object({<br>      license_configuration_arn = string<br>    }), null)<br>    maintenance_options = optional(object({<br>      auto_recovery = string<br>    }), null)<br>    metadata_options = optional(object({<br>      http_endpoint               = string<br>      http_put_response_hop_limit = number<br>      http_tokens                 = string<br>      instance_metadata_tags      = string<br>    }), null)<br>    network_interfaces = optional(list(object({<br>      associate_public_ip_address = bool<br>      subnet_id                   = string<br>    })), [])<br>    placement = optional(object({<br>      affinity                = optional(string)<br>      availability_zone       = optional(string)<br>      group_name              = optional(string)<br>      host_id                 = optional(string)<br>      host_resource_group_arn = optional(string)<br>      spread_domain           = optional(string)<br>      tenancy                 = optional(string)<br>      partition_number        = optional(number)<br>    }), {})<br>    private_dns_name_options = optional(object({<br>      enable_resource_name_dns_aaaa_record = optional(bool)<br>      enable_resource_name_dns_a_record    = optional(bool)<br>      hostname_type                        = optional(string)<br>    }), null)<br><br>    ram_disk_id = optional(string)<br><br>    tag_specifications = optional(object({<br>      resource_type = optional(string)<br>      tags          = optional(map(string))<br>    }), {})<br>  })</pre> | <pre>{<br>  "create": false,<br>  "instance_type": "t2.micro"<br>}</pre> | no |
| <a name="input_lifecycle_hooks"></a> [lifecycle\_hooks](#input\_lifecycle\_hooks) | List of lifecycle hooks for the autoscaling group | <pre>list(object({<br>    name                    = string<br>    default_result          = string<br>    heartbeat_timeout       = number<br>    lifecycle_transition    = string<br>    notification_metadata   = string<br>    notification_target_arn = string<br>    role_arn                = string<br>  }))</pre> | `[]` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | Configuration for the placement group | <pre>object({<br>    name            = optional(string, null)<br>    strategy        = optional(string, "cluster")<br>    partition_count = optional(number, 2)<br>    spread_level    = optional(string, "rack")<br>  })</pre> | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used to find the appropriate AMI for the launch configuration | `string` | n/a | yes |
| <a name="input_propagate_tags_at_launch"></a> [propagate\_tags\_at\_launch](#input\_propagate\_tags\_at\_launch) | Specifies whether tags are propagated to the instances in the Auto Scaling group | `bool` | `true` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs that will be applied to the autoscaling group | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Arbitrary tags that will be applied to all resources created in this module | `map(string)` | `{}` | no |
| <a name="input_vpc_cluster"></a> [vpc\_cluster](#input\_vpc\_cluster) | Boolean flag to indicate if the cluster is within a VPC | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami"></a> [ami](#output\_ami) | n/a |
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | n/a |
| <a name="output_cloud_init"></a> [cloud\_init](#output\_cloud\_init) | n/a |
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
