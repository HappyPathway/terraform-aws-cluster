terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=5.84.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

run "validation_min_max_capacity" {
  command = plan
  expect_failures = [
    {
      module = root
      severity = "error"
      message = "When create is true, desired_capacity must be between min_size and max_size."
    }
  ]

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
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
      min_size         = 2
      max_size         = 3
      desired_capacity = 1  # Invalid: desired < min
      subnets         = ["subnet-12345678"]
    }
  }
}

run "validation_subnet_requirement" {
  command = plan
  expect_failures = [
    {
      module = root
      severity = "error"
      message = "When create is true, either subnets or availability_zones must be specified."
    }
  ]

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
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
    }
  }
}

run "validation_health_check_type" {
  command = plan
  expect_failures = [
    {
      module = root
      severity = "error"
      message = "health_check_type must be either 'EC2' or 'ELB'."
    }
  ]

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    ami = {
      most_recent = true
      owners      = ["amazon"]
      filters = [{
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }]
    }
    auto_scaling = {
      create             = true
      min_size          = 1
      max_size          = 3
      desired_capacity  = 2
      subnets          = ["subnet-12345678"]
      health_check_type = "INVALID"
    }
  }
}

run "validation_scaling_policy_type" {
  command = plan
  expect_failures = [
    {
      module = root
      severity = "error"
      message = "policy_type must be one of: SimpleScaling, StepScaling, TargetTrackingScaling, or PredictiveScaling"
    }
  ]

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
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
      subnets         = ["subnet-12345678"]
    }
    auto_scaling_policy = {
      name        = "test-policy"
      policy_type = "InvalidType"
    }
  }
}

run "validation_target_value" {
  command = plan
  expect_failures = [
    {
      module = root
      severity = "error"
      message = "target_value in target_tracking_configuration must be greater than 0"
    }
  ]

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
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
      subnets         = ["subnet-12345678"]
    }
    auto_scaling_policy = {
      name = "test-policy"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = -1.0
      }
    }
  }
}

run "validation_instance_refresh_strategy" {
  command = plan
  expect_failures = [
    {
      module = root
      severity = "error"
      message = "instance_refresh strategy must be 'Rolling' when specified."
    }
  ]

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
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
      subnets         = ["subnet-12345678"]
      instance_refresh = {
        strategy = "Invalid"
      }
    }
  }
}