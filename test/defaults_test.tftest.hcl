provider "aws" {
  region = "us-west-2"
}

run "setup_infrastructure" {
  command = apply
  module {
    source = "./setup"
  }
}

run "verify_health_check_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
    }
    launch_template = {
      create = true
      use_launch_template = true
      name = run.setup_infrastructure.launch_template_name
      id = run.setup_infrastructure.launch_template_id
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].health_check_type == "ELB"
    error_message = "health_check_type should default to ELB"
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].health_check_grace_period == 300
    error_message = "health_check_grace_period should be 300 seconds"
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].capacity_rebalance == true
    error_message = "capacity_rebalance should be enabled by default"
  }
}

run "verify_monitoring_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    ami = {
      most_recent = true
      owners      = ["amazon"]
      filters = [{
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }]
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].metrics_granularity == "1Minute"
    error_message = "metrics_granularity should be 1Minute"
  }

  assert {
    condition = contains(aws_autoscaling_group.asg[0].enabled_metrics, "GroupMinSize") && contains(aws_autoscaling_group.asg[0].enabled_metrics, "GroupMaxSize") && contains(aws_autoscaling_group.asg[0].enabled_metrics, "GroupDesiredCapacity") && contains(aws_autoscaling_group.asg[0].enabled_metrics, "GroupInServiceInstances")
    error_message = "Default metrics should be enabled"
  }
}

run "verify_instance_refresh_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    ami = {
      most_recent = true
      owners      = ["amazon"]
      filters = [{
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }]
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
      instance_refresh = {
        strategy = "Rolling"
        preferences = {
          min_healthy_percentage = 90
          checkpoint_percentages = [20, 40, 60, 80, 100]
          auto_rollback = true
        }
      }
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].instance_refresh[0].strategy == "Rolling"
    error_message = "Instance refresh strategy should be Rolling"
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].instance_refresh[0].preferences[0].min_healthy_percentage == 90 && length(aws_autoscaling_group.asg[0].instance_refresh[0].preferences[0].checkpoint_percentages) == 5 && aws_autoscaling_group.asg[0].instance_refresh[0].preferences[0].auto_rollback == true
    error_message = "Instance refresh settings should have proper defaults"
  }
}

run "verify_launch_template_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
    }
    launch_template = {
      create = true
      use_launch_template = true
      name = run.setup_infrastructure.launch_template_name
      id = run.setup_infrastructure.launch_template_id
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
  }

  assert {
    condition     = aws_launch_template.lt[0].name == var.project_name
    error_message = "Launch template name should match project name"
  }

  assert {
    condition     = aws_launch_template.lt[0].update_default_version == true
    error_message = "Launch template should update default version"
  }
}

run "verify_scaling_policy_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
    }
    launch_template = {
      create = true
      use_launch_template = true
      name = run.setup_infrastructure.launch_template_name
      id = run.setup_infrastructure.launch_template_id
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].policy_type == "TargetTrackingScaling"
    error_message = "Policy type should be TargetTrackingScaling"
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].target_tracking_configuration[0].target_value == 50.0
    error_message = "Target tracking value should be 50.0"
  }
}

run "verify_lifecycle_hook_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    ami = {
      most_recent = true
      owners      = ["amazon"]
      filters = [{
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }]
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
    lifecycle_hooks = [{
      name = "test-hook"
      default_result = "CONTINUE"
      heartbeat_timeout = 300
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = "test metadata"
      notification_target_arn = run.setup_infrastructure.sns_topic_arn
      role_arn = run.setup_infrastructure.iam_role_arn
    }]
  }

  assert {
    condition     = aws_autoscaling_lifecycle_hook.hook["test-hook"].default_result == "CONTINUE"
    error_message = "Lifecycle hook default result should be CONTINUE"
  }

  assert {
    condition     = aws_autoscaling_lifecycle_hook.hook["test-hook"].heartbeat_timeout == 300
    error_message = "Lifecycle hook heartbeat timeout should be 300 seconds"
  }
}

run "verify_schedule_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    ami = {
      most_recent = true
      owners      = ["amazon"]
      filters = [{
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }]
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
    autoscaling_schedule = [{
      scheduled_action_name = "scale-up"
      min_size = 2
      max_size = 4
      desired_capacity = 3
      recurrence = "0 9 * * *"
    }]
  }

  assert {
    condition     = aws_autoscaling_schedule.asg_schedule["scale-up"].recurrence == "0 9 * * *"
    error_message = "Schedule recurrence should be set correctly"
  }

  assert {
    condition     = aws_autoscaling_schedule.asg_schedule["scale-up"].desired_capacity == 3
    error_message = "Schedule desired capacity should be set correctly"
  }
}

run "verify_traffic_source_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    ami = {
      most_recent = true
      owners      = ["amazon"]
      filters = [{
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }]
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
    autoscaling_traffic_source_attachment = {
      identifier = run.setup_infrastructure.target_group_arn
      type = "elb"
    }
  }

  assert {
    condition     = aws_autoscaling_traffic_source_attachment.traffic_source_attachment[0].traffic_source[0].type == "elb"
    error_message = "Traffic source type should be set correctly"
  }
}

run "verify_warm_pool_defaults" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    ami = {
      most_recent = true
      owners      = ["amazon"]
      filters = [{
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }]
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      subnets         = run.setup_infrastructure.subnet_ids
      warm_pool = {
        pool_state = "Stopped"
        min_size = 1
        max_group_prepared_capacity = 2
        instance_reuse_policy = {
          reuse_on_scale_in = true
        }
      }
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].warm_pool[0].pool_state == "Stopped"
    error_message = "Warm pool state should be set correctly"
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].warm_pool[0].instance_reuse_policy[0].reuse_on_scale_in == true
    error_message = "Warm pool instance reuse policy should be set correctly"
  }

  assert {
    condition     = aws_autoscaling_group.asg[0].warm_pool[0].min_size == 1 && aws_autoscaling_group.asg[0].warm_pool[0].max_group_prepared_capacity == 2
    error_message = "Warm pool capacity settings should be set correctly"
  }
}