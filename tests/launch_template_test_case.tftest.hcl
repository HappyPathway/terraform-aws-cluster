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
  }
}

run "launch_template_test_case" {
  command = apply

  assert {
    condition     = aws_autoscaling_group.asg != null && one(aws_autoscaling_group.asg).id != ""
    error_message = "ASG was not created"
  }
}
