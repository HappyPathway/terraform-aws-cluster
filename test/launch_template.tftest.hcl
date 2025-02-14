provider "aws" {
  region = "us-west-2"
}

run "setup_infrastructure" {
  command = apply
  module {
    source = "./setup"
  }
}

run "launch_template" {
  command = apply
  
  variables {
    project_name  = "test-project"
    instance_type = "t2.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
    }
    launch_template = {
      key_name            = "terraform-aws-cluster"
      use_launch_template = true
      create             = true
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id                   = run.setup_infrastructure.subnet_ids[0]
      }]
    }
    auto_scaling = {
      create           = true
      min_size         = 1
      max_size         = 2
      desired_capacity = 1
      subnets         = run.setup_infrastructure.subnet_ids
    }
  }

  assert {
    condition     = aws_autoscaling_group.asg != null
    error_message = "ASG was not created"
  }
}
