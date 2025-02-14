terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_vpcs" "test" {
  tags = {
    service = "production"
  }
}

data "aws_subnets" "subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.test[0].id]
  }
}

resource "aws_internet_gateway" "test" {
  vpc_id = data.aws_vpc.test.id[0]

  tags = {
    Environment = "test"
  }
}

resource "aws_route_table" "test" {
  vpc_id = data.aws_vpc.test[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test.id
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_route_table_association" "test" {
  subnet_id      = aws_subnet.test.id
  route_table_id = aws_route_table.test.id
}

resource "aws_route_table_association" "test_2" {
  subnet_id      = aws_subnet.test_2.id
  route_table_id = aws_route_table.test.id
}

resource "aws_security_group" "test" {
  name        = "terraform-aws-cluster-test"
  description = "Test security group for terraform-aws-cluster"
  vpc_id      = data.aws_vpc.test[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_sns_topic" "test" {
  name = "terraform-aws-cluster-test"
}

resource "aws_iam_role" "test" {
  name = "terraform-aws-cluster-test"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "test" {
  name = "terraform-aws-cluster-test"
  role = aws_iam_role.test.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [aws_sns_topic.test.arn]
      }
    ]
  })
}

resource "aws_launch_template" "test" {
  name = "terraform-aws-cluster"
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.test.id
    security_groups             = [aws_security_group.test.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = "test"
    }
  }
}

resource "aws_lb_target_group" "test" {
  name     = "terraform-aws-cluster-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.test[0].id

  health_check {
    enabled = true
    path    = "/"
  }
}

resource "aws_lb" "test" {
  name               = "terraform-aws-cluster-test"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test.id]
  subnets           = [aws_subnet.test.id, aws_subnet.test_2.id]

  tags = {
    Environment = "test"
  }
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

output "vpc_id" {
  value = data.aws_vpcs.foo.ids[0]
}

output "subnet_id" {
  value = data.aws_subnets.subnet.ids[0]
}

output "subnet_ids" {
  value = [aws_subnet.test.id, aws_subnet.test_2.id]
}

output "launch_template_id" {
  value = aws_launch_template.test.id
}

output "launch_template_name" {
  value = aws_launch_template.test.name
}

output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "security_group_id" {
  value = aws_security_group.test.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.test.arn
}

output "iam_role_arn" {
  value = aws_iam_role.test.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.test.arn
}

output "alb_arn" {
  value = aws_lb.test.arn
}

output "alb_dns_name" {
  value = aws_lb.test.dns_name
}