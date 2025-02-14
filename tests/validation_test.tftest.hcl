provider "aws" {
  region = "us-west-2"
}

run "setup_infrastructure" {
  command = apply
  module {
    source = "./tests/setup"
  }
}

variables {
  desired_capacity_error = "When create is true, desired_capacity must be between min_size and max_size"
  subnet_error = "When create is true, either subnets or availability_zones must be specified"
  health_check_error = "health_check_type must be either \"EC2\" or \"ELB\""
  policy_type_error = "policy_type must be one of: SimpleScaling, StepScaling, TargetTrackingScaling, or PredictiveScaling"
  target_value_error = "target_value in target_tracking_configuration must be greater than 0"
  refresh_strategy_error = "instance_refresh strategy must be \"Rolling\" when specified"
}

run "validation_min_max_capacity" {
  command = apply
  expect_failures = [var.auto_scaling]
  
  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    auto_scaling = {
      create           = true
      min_size         = 2
      max_size         = 3
      desired_capacity = 1  # Invalid: desired < min
      subnets          = [run.setup_infrastructure.subnet_id]
      health_check_type = "ELB"  # Valid health check type
      instance_refresh = null
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_id
      }]
    }
  }
}

run "validation_subnet_requirement" {
  command = apply
  expect_failures = [var.auto_scaling]

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
      health_check_type = "ELB"  # Valid health check type
      instance_refresh = null
      # Missing subnets intentionally for test
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_id
      }]
    }
  }
}

run "validation_health_check_type" {
  command = apply
  expect_failures = [var.auto_scaling]

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    auto_scaling = {
      create             = true
      min_size          = 1
      max_size          = 3
      desired_capacity  = 2
      subnets          = [run.setup_infrastructure.subnet_id]
      health_check_type = "INVALID"  # Invalid health check type
      instance_refresh = null
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_id
      }]
    }
  }
}

run "validation_policy_type" {
  command = apply
  expect_failures = [var.auto_scaling_policy]

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
      health_check_type = "ELB"  # Valid health check type
      instance_refresh = null
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
      name        = "test-policy"
      policy_type = "InvalidType"  # Invalid policy type
      target_tracking_configuration = null
      cooldown = null
      estimated_instance_warmup = null
    }
  }
}

run "validation_target_value" {
  command = apply
  expect_failures = [var.auto_scaling_policy]

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
      health_check_type = "ELB"  # Valid health check type
      instance_refresh = null
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
        target_value = -1.0  # Invalid target value
      }
      cooldown = null
      estimated_instance_warmup = null
    }
  }
}

run "validation_instance_refresh_strategy" {
  command = apply
  expect_failures = [var.auto_scaling]

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
      health_check_type = "ELB"  # Valid health check type
      instance_refresh = {
        strategy = "Invalid"  # Invalid strategy
      }
    }
    launch_template = {
      create = true
      use_launch_template = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_id
      }]
    }
  }
}