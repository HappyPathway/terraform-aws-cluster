variables {
  project_name  = "test-project"
  instance_type = "t2.micro"
  ami = {
    most_recent = true
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-20.04*"]
      },
      {
        name   = "virtualization-type"
        values = ["hvm"]
      }
    ]
  }
  security_group_ids = []
  tags               = {}
  auto_scaling = {
    create             = true
    configuration_type = "mixed_instances_policy"
    min_size           = 1
    max_size           = 2
    desired_capacity   = 1
    subnets            = ["subnet-12345678"]
    availability_zones = ["us-east-1a"]
    mixed_instances_policy = {
      launch_template = {
        key_name            = "example-key"
        use_launch_template = true
        create              = true
        network_interfaces = [{
          associate_public_ip_address = true
          subnet_id                   = "subnet-12345678"
        }]
      }
      instances_distribution = {
        on_demand_base_capacity                  = 1
        on_demand_percentage_above_base_capacity = 50
        spot_allocation_strategy                 = "lowest-price"
      }
    }
  }
}

run "test_mixed_instances_policy" {
  command = plan

  assert {
    condition     = aws_autoscaling_group.asg_mixed_instances_policy.id != ""
    error_message = "Mixed instances policy ASG was not created"
  }
}
