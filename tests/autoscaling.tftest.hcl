
provider "aws" {
  region = "us-east-1"
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
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-20231128"]
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
    mixed_instances_policy = {
      launch_template = {
        launch_template_specification = {
          launch_template_id = "lt-12345678"
          version            = "$Latest"
        }
      }
      instances_distribution = {
        on_demand_base_capacity                  = 1
        on_demand_percentage_above_base_capacity = 50
        spot_allocation_strategy                 = "lowest-price"
      }
  } }

}

run "test_mixed_instances_policy" {
  command = plan

  assert {
    condition     = one(aws_autoscaling_group.asg_mixed_instances_policy).id != ""
    error_message = "Mixed instances policy ASG was not created"
  }
}
