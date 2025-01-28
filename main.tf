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
  most_recent      = var.ami.most_recent
  owners           = var.ami.owners
  executable_users = var.ami.executable_users
  name_regex       = var.ami.name_regex
  dynamic "filter" {
    for_each = var.ami.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

resource "aws_launch_configuration" "lc" {
  name_prefix                 = "${var.launch_configuration.project_name}-"
  image_id                    = data.aws_ami.ami.id
  iam_instance_profile        = var.launch_configuration.iam_instance_profile
  instance_type               = var.launch_configuration.instance_type
  associate_public_ip_address = var.launch_configuration.associate_public_ip_address
  placement_tenancy           = var.launch_configuration.placement_tenancy
  key_name                    = var.launch_configuration.key_name
  security_groups             = var.launch_configuration.security_group_ids
  user_data                   = data.cloudinit_config.cloud_init.rendered
  enable_monitoring           = var.launch_configuration.enable_monitoring
  ebs_optimized               = var.launch_configuration.ebs_optimized

  dynamic "metadata_options" {
    for_each = var.launch_configuration.metadata_options == null ? [] : [1]
    content {
      http_tokens                 = var.launch_configuration.http_tokens
      http_put_response_hop_limit = var.launch_configuration.http_put_response_hop_limit
      http_endpoint               = var.launch_configuration.http_endpoint
    }
  }

  dynamic "root_block_device" {
    for_each = var.root_volume.volume_size > 0 ? [1] : []
    content {
      iops                  = root_block_device.value.iops
      throughput            = root_block_device
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      snapshot_id           = ebs_block_device.value.snapshot_id
      iops                  = ebs_block_device.value.iops
      throughput            = ebs_block_device.value.throughput
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
      no_device             = ebs_block_device.value.no_device
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_devices
    content {
      device_name  = ephemeral_block_device.value.device_name
      virtual_name = ephemeral_block_device.value.virtual_name
      no_device    = ephemeral_block_device.value.no_device
    }
  }

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

resource "aws_autoscaling_group" "asg" {
  name                 = var.project_name
  launch_configuration = aws_launch_configuration.lc.name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = var.subnets
  placement_group      = var.placement_group

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = var.propagate_tags_at_launch
    }
  }
}
