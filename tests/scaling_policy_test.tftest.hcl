provider "aws" {
  region = "us-west-2"
}

run "setup_infrastructure" {
  command = apply
  module {
    source = "./tests/setup"
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
      subnets         = [run.setup_infrastructure.subnet_id]
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_id
      }]
    }
    auto_scaling_policy = {
      name = "test-policy"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    }
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].policy_type == "TargetTrackingScaling"
    error_message = "Default policy type should be TargetTrackingScaling"
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].metric_aggregation_type == "Average"
    error_message = "Default metric aggregation should be Average"
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].estimated_instance_warmup == 300
    error_message = "Default warmup period should be 300 seconds"
  }
}

run "verify_predictive_scaling_defaults" {
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
      subnets         = [run.setup_infrastructure.subnet_id]
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_id
      }]
    }
    auto_scaling_policy = {
      name = "test-predictive-policy"
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        metric_specification = {
          target_value = 70.0
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label = "test"
          }
        }
      }
    }
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].predictive_scaling_configuration[0].mode == "ForecastAndScale"
    error_message = "Predictive scaling mode should default to ForecastAndScale"
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].predictive_scaling_configuration[0].scheduling_buffer_time == 300
    error_message = "Default scheduling buffer time should be 300 seconds"
  }

  assert {
    condition     = aws_autoscaling_policy.asg_policy[0].predictive_scaling_configuration[0].max_capacity_breach_behavior == "HonorMaxCapacity"
    error_message = "Should honor max capacity by default"
  }
}