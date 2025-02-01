provider "aws" {
  region = "us-east-2"
}

variables {
  project_name  = "test-project"
  instance_type = "t2.micro"
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
  security_group_ids = []
  tags               = {}
  launch_template = {
    key_name            = "terraform-aws-cluster"
    use_launch_template = true
    create              = true
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
        spot_max_price                           = "0.05"
      }
      launch_template = {
        launch_template_specification = {
          launch_template_id = "lt-0abcd1234abcd1234"
          version            = "$Latest"
        }
        override = [
          {
            instance_type = "t2.micro"
          },
          {
            instance_type = "t3.micro"
          }
        ]
      }
    }
  }
}

run "mixed_policy_test_case_1" {
  command = apply

  assert {
    condition     = aws_autoscaling_group.asg != null && one(aws_autoscaling_group.asg).id != ""
    error_message = "ASG was not created"
  }
}

variables {
  project_name  = "test-project"
  instance_type = "t2.micro"
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
  security_group_ids = []
  tags               = {}
  launch_template = {
    key_name            = "terraform-aws-cluster"
    use_launch_template = true
    create              = true
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
        on_demand_base_capacity                  = 2
        on_demand_percentage_above_base_capacity = 75
        spot_allocation_strategy                 = "capacity-optimized"
        spot_instance_pools                      = 3
        spot_max_price                           = "0.10"
      }
      launch_template = {
        launch_template_specification = {
          launch_template_id = "lt-0abcd1234abcd1234"
          version            = "$Latest"
        }
        override = [
          {
            instance_type = "t2.micro"
          },
          {
            instance_type = "t3.micro"
          }
        ]
      }
    }
  }
}

run "mixed_policy_test_case_2" {
  command = apply

  assert {
    condition     = aws_autoscaling_group.asg != null && one(aws_autoscaling_group.asg).id != ""
    error_message = "ASG was not created"
  }
}
