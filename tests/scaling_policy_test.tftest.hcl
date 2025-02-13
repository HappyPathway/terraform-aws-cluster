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

run "verify_scaling_policy_defaults" {
  command = plan

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
        target_value = 50.0
      }
    }
  }

  mock_provider "aws" {
    mock_resource "aws_autoscaling_policy" {
      defaults = {
        id = "test-policy"
      }

      assert "policy_type_default" {
        condition     = self.policy_type == "TargetTrackingScaling"
        error_message = "Default policy type should be TargetTrackingScaling"
      }

      assert "metric_aggregation" {
        condition     = self.metric_aggregation_type == "Average"
        error_message = "Default metric aggregation should be Average"
      }

      assert "warmup_period" {
        condition     = self.estimated_instance_warmup == 300
        error_message = "Default warmup period should be 300 seconds"
      }
    }
  }
}

run "verify_predictive_scaling_defaults" {
  command = plan

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

  mock_provider "aws" {
    mock_resource "aws_autoscaling_policy" {
      defaults = {
        id = "test-policy"
      }

      assert "predictive_defaults" {
        condition = self.predictive_scaling_configuration[0].mode == "ForecastAndScale" &&
                   self.predictive_scaling_configuration[0].scheduling_buffer_time == 300
        error_message = "Predictive scaling should have correct defaults"
      }

      assert "capacity_behavior" {
        condition = self.predictive_scaling_configuration[0].max_capacity_breach_behavior == "HonorMaxCapacity"
        error_message = "Should honor max capacity by default"
      }
    }
  }
}