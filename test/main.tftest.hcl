provider "aws" {
  region = "us-west-2"
}

run "setup_infrastructure" {
  command = apply
  module {
    source = "./setup"
  }
}

run "basic_cluster_creation" {
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
      network_interfaces = [{
        associate_public_ip_address = true
        subnet_id = run.setup_infrastructure.subnet_ids[0]
      }]
    }
  }

  assert {
    condition     = length(aws_autoscaling_group.asg) > 0
    error_message = "Auto Scaling Group was not created"
  }

  assert {
    condition     = length(aws_launch_template.lt) > 0
    error_message = "Launch Template was not created"
  }
}

run "verify_tags_propagation" {
  command = apply

  variables {
    project_name  = "test-asg"
    instance_type = "t3.micro"
    security_group_ids = [run.setup_infrastructure.security_group_id]
    tags = {
      Environment = "test"
      Project     = "terraform-aws-cluster"
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
  }

  assert {
    condition     = can(aws_autoscaling_group.asg[0].tag)
    error_message = "Tags should be propagated to ASG"
  }
}

run "verify_no_launch_template" {
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
      create = false
      use_launch_template = false
    }
  }

  assert {
    condition     = length(aws_launch_template.lt) == 0
    error_message = "Launch Template should not be created when disabled"
  }
}