module "predictive_scaling_autoscaling" {
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
  }
  auto_scaling_policy = {
    name                      = "predictive-scaling-policy"
    policy_type               = "PredictiveScaling"
    predictive_scaling_configuration = {
      metric_specification = {
        target_value = 50.0
        predefined_load_metric_specification = {
          predefined_metric_type = "ASGTotalCPUUtilization"
        }
      }
      mode                   = "ForecastAndScale"
      scheduling_buffer_time = 300
    }
  }
}
