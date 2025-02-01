provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group"
  vpc_id      = "vpc-12345678"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "autoscaling" {
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
  security_group_ids = [aws_security_group.example.id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  auto_scaling = {
    create           = true
    min_size         = 1
    max_size         = 1
    desired_capacity = 1
    subnets          = ["subnet-12345678"]
    target_group_arns = [aws_lb_target_group.example.arn]
  }
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = "subnet-12345678"
    }]
  }
}

resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example.id]
  subnets            = ["subnet-12345678"]
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-12345678"
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}
