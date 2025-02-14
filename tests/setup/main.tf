terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource random_pet "pet" {
  length    = 2
  separator = "-"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "test" {
  vpc_id     = aws_vpc.test.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "test" {
  name        = "test-${random_pet.pet.id}"
  description = "Test security group for terraform-aws-cluster"
  vpc_id      = aws_vpc.test.id

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
  name = "test-${random_pet.pet.id}"
}

resource "aws_iam_role" "test" {
  name = "test-${random_pet.pet.id}"

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
  name = "test-${random_pet.pet.id}"
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
  name = "test-${random_pet.pet.id}"
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
  name     = "test-${random_pet.pet.id}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test.id

  health_check {
    enabled = true
    path    = "/"
  }
}
