module "mixed_instances_autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
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
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
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
      }
      launch_template = {
        launch_template_specification = {
          launch_template_id = aws_launch_template.example.id
          version            = "$Latest"
        }
        override = [
          {
            instance_type = "t3.micro"
          }
        ]
      }
    }
  }
}
