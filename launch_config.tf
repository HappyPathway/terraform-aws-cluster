
resource "aws_launch_configuration" "lc" {
  count                       = var.launch_configuration.create ? 0 : 1
  name_prefix                 = "${var.project_name}-"
  image_id                    = data.aws_ami.ami.id
  iam_instance_profile        = var.launch_configuration.iam_instance_profile
  instance_type               = var.instance_type
  associate_public_ip_address = var.launch_configuration.associate_public_ip_address
  placement_tenancy           = var.launch_configuration.placement_tenancy
  key_name                    = var.launch_configuration.key_name
  security_groups             = var.security_group_ids
  user_data                   = local.cloud_init
  enable_monitoring           = var.launch_configuration.enable_monitoring
  ebs_optimized               = var.launch_configuration.ebs_optimized

  dynamic "metadata_options" {
    for_each = var.launch_configuration.metadata_options == null ? [] : [1]
    content {
      http_tokens                 = var.launch_configuration.metadata_options.http_tokens
      http_put_response_hop_limit = var.launch_configuration.metadata_options.http_put_response_hop_limit
      http_endpoint               = var.launch_configuration.metadata_options.http_endpoint
    }
  }

  dynamic "root_block_device" {
    for_each = var.root_volume.volume_size > 0 ? [var.root_volume] : []
    content {
      iops                  = root_block_device.value.iops
      throughput            = root_block_device.value.throughput
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

data aws_launch_configuration "lc" {
  count = var.launch_configuration.create ? 0 : var.launch_configuration.use_launch_configuration ? 1 : 0
  name  = var.launch_configuration.name
}

locals {
  launch_configuration = var.launch_configuration.create ? one(aws_launch_configuration.lc) : var.launch_configuration.use_launch_configuration ? one(data.aws_launch_configuration.lc) : null
}