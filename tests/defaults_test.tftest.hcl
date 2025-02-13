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

run "verify_health_check_defaults" {
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
  }

  mock_provider "aws" {
    mock_data "aws_ami" {
      defaults = {
        id           = "ami-12345678"
        name         = "mock-ami"
        description  = "Mock AMI for testing"
        owner_id     = "123456789012"
        architecture = "x86_64"
      }
    }

    mock_resource "aws_autoscaling_group" {
      defaults = {
        id = "test-asg"
      }

      assert "health_check_defaults" {
        condition     = self.health_check_type == "ELB"
        error_message = "health_check_type should default to ELB"
      }

      assert "grace_period" {
        condition     = self.health_check_grace_period == 300
        error_message = "health_check_grace_period should be 300 seconds"
      }

      assert "capacity_rebalance" {
        condition     = self.capacity_rebalance == true
        error_message = "capacity_rebalance should be enabled by default"
      }
    }
  }
}

run "verify_monitoring_defaults" {
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
  }

  mock_provider "aws" {
    mock_resource "aws_autoscaling_group" {
      defaults = {
        id = "test-asg"
      }

      assert "metrics_granularity" {
        condition     = self.metrics_granularity == "1Minute"
        error_message = "metrics_granularity should be 1Minute"
      }

      assert "enabled_metrics" {
        condition = contains(self.enabled_metrics, "GroupMinSize") && 
                   contains(self.enabled_metrics, "GroupMaxSize") && 
                   contains(self.enabled_metrics, "GroupDesiredCapacity") && 
                   contains(self.enabled_metrics, "GroupInServiceInstances")
        error_message = "Default metrics should be enabled"
      }
    }
  }
}

run "verify_instance_refresh_defaults" {
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
      instance_refresh = {
        strategy = "Rolling"
      }
    }
  }

  mock_provider "aws" {
    mock_resource "aws_autoscaling_group" {
      defaults = {
        id = "test-asg"
      }

      assert "instance_refresh_strategy" {
        condition     = self.instance_refresh[0].strategy == "Rolling"
        error_message = "Instance refresh strategy should be Rolling"
      }

      assert "instance_refresh_defaults" {
        condition = self.instance_refresh[0].preferences[0].min_healthy_percentage == 90 &&
                   length(self.instance_refresh[0].preferences[0].checkpoint_percentages) == 5 &&
                   self.instance_refresh[0].preferences[0].auto_rollback == true
        error_message = "Instance refresh settings should have proper defaults"
      }
    }
  }
}