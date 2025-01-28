# this module will create an autoscaling group, and associated launch configuration, and a security group
# it will need take in aribtrary of tags that will be applied to all resources that are created in this module
# it will also need to take in a list of subnets that the autoscaling group will be deployed to
# it will also need to take in a list of security group ids that will be applied to the autoscaling group
# it will also need to find the appropriate AMI to use for the launch configuration based on the project name
# it will create a cloud-init configuration that will be passed in to user-data for the launch configuration
# it will also need to take in a list of volume mappings that will be applied to the launch configuration
# it will also need to take in the instance type that will be used for the launch configuration
# it will also need to take in the key name that will be used for the launch configuration

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.project_name}-*"]
  }
}

resource "aws_launch_configuration" "lc" {
  name          = var.project_name
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups = var.security_group_ids
  user_data       = data.cloudinit_config.cloud_init.rendered
  lifecycle {
    ignore_changes = [image_id]
  }
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  # change to loop over a list of files
  dynamic "part" {
    for_each = var.file_list
    content {
      filename     = part.value.filename
      content_type = part.value.content_type
      content      = file("${part.value.filename}")
    }
  }

  dynamic "part" {
    for_each = var.cloud_init_config
    content {
      filename     = part.value.filename
      content_type = part.value.content_type
      content      = file("${path.module}/${part.value.filename}")
    }
  }
}

<<<<<<< HEAD
resource "aws_autoscaling_group" "example" {
    name                 = "example-autoscaling-group"
    launch_configuration = aws_launch_configuration.example.name
    min_size             = var.min_size
    max_size             = var.max_size
    desired_capacity     = var.desired_capacity
    vpc_zone_identifier  = var.subnets
    tags                 = var.tags
    placement_group      = var.placement_group
    dynamic "tag" {
        for_each = var.tags
        content {
            key                 = tag.key
            value               = tag.value
            propagate_at_launch = true
        }
=======
resource "aws_autoscaling_group" "asg" {
  name                 = var.project_name
  launch_configuration = aws_launch_configuration.lc.name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = var.subnets

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = var.propagate_tags_at_launch
>>>>>>> 1358ac8c996bde0bae327a54731957e364eba8ae
    }
  }
}
