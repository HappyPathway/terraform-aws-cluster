resource "aws_launch_template" "lt" {
  count         = var.launch_template.create ? 0 : 1
  name          = var.project_name
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type

  dynamic "block_device_mappings" {
    for_each = var.launch_template.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        volume_size = block_device_mappings.value.ebs.volume_size
        volume_type = block_device_mappings.value.ebs.volume_type
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.launch_template.capacity_reservation_specification == null ? [] : [var.launch_template.capacity_reservation_specification]
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference
    }
  }

  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_options == null ? [] : [var.launch_template.cpu_options]
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = var.launch_template.credit_specification == null ? [] : [var.launch_template.credit_specification]
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  disable_api_stop        = var.launch_template.disable_api_stop
  disable_api_termination = var.launch_template.disable_api_termination

  ebs_optimized = var.launch_template.ebs_optimized

  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_specifications == null ? [] : [var.launch_template.elastic_gpu_specifications]
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = var.launch_template.elastic_inference_accelerator == null ? [] : [var.launch_template.elastic_inference_accelerator]
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = var.launch_template.enclave_options == null ? [] : [var.launch_template.enclave_options]
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = var.launch_template.hibernation_options == null ? [] : [var.launch_template.hibernation_options]
    content {
      configured = hibernation_options.value.configured
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile == null ? [] : [var.launch_template.iam_instance_profile]
    content {
      name = iam_instance_profile.value.name
    }
  }

  instance_initiated_shutdown_behavior = "terminate"
  dynamic "instance_market_options" {
    for_each = var.launch_template.instance_market_options == null ? [] : [for option in var.launch_template.instance_market_options : option]
    content {
      market_type = instance_market_options.value.market_type
      spot_options {
        block_duration_minutes         = instance_market_options.value.spot_options.block_duration_minutes
        instance_interruption_behavior = instance_market_options.value.spot_options.instance_interruption_behavior
        max_price                      = instance_market_options.value.spot_options.max_price
        spot_instance_type             = instance_market_options.value.spot_options.spot_instance_type
        valid_until                    = instance_market_options.value.spot_options.valid_until
      }
    }
  }

  dynamic "instance_requirements" {
    for_each = var.launch_template.instance_requirements == null ? [] : [var.launch_template.instance_requirements]
    content {
      dynamic "vcpu_count" {
        for_each = instance_requirements.value.vcpu_count == null ? [] : [instance_requirements.value.vcpu_count]
        content {
          min = instance_requirements.value.vcpu_count.min
          max = instance_requirements.value.vcpu_count.max
        }
      }
      dynamic "memory_mib" {
        for_each = instance_requirements.value.memory_mib == null ? [] : [instance_requirements.value.memory_mib]
        content {
          min = instance_requirements.value.memory_mib.min
          max = instance_requirements.value.memory_mib.max
        }
      }
    }
  }

  kernel_id = var.launch_template.kernel_id
  key_name  = var.launch_template.key_name

  dynamic "license_specification" {
    for_each = var.launch_template.license_specification == null ? [] : [var.launch_template.license_specification]
    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  dynamic "maintenance_options" {
    for_each = var.launch_template.maintenance_options == null ? [] : [var.launch_template.maintenance_options]
    content {
      auto_recovery = maintenance_options.value
    }
  }

  dynamic "metadata_options" {
    for_each = var.launch_template.metadata_options == null ? [] : [var.launch_template.metadata_options]
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_tokens                 = metadata_options.value.http_tokens
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  monitoring {
    enabled = true
  }

  dynamic "network_interfaces" {
    for_each = var.launch_template.network_interfaces == null ? [] : var.launch_template.network_interfaces
    content {
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      subnet_id                   = network_interfaces.value.subnet_id
    }
  }

  dynamic "placement" {
    for_each = var.launch_template.placement == null ? [] : [var.launch_template.placement]
    content {
      availability_zone = placement.value.availability_zone
    }
  }

  dynamic "private_dns_name_options" {
    for_each = var.launch_template.private_dns_name_options == null ? [] : [var.launch_template.private_dns_name_options]
    content {
      enable_resource_name_dns_aaaa_record = private_dns_name_options.value.enable_resource_name_dns_aaaa_record
      enable_resource_name_dns_a_record    = private_dns_name_options.value.enable_resource_name_dns_a_record
      hostname_type                        = private_dns_name_options.value.hostname_type
    }
  }

  ram_disk_id = var.launch_template.ram_disk_id

  security_group_names = var.vpc_cluster ? null : var.security_group_ids

  dynamic "tag_specifications" {
    for_each = var.launch_template.tag_specifications == null ? [] : [var.launch_template.tag_specifications]
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  tags                   = var.tags
  update_default_version = true
  user_data              = local.cloud_init
  vpc_security_group_ids = var.vpc_cluster ? var.security_group_ids : null
}


data "aws_launch_template" "lt" {
  count = var.launch_template.create == false && var.launch_template.use_launch_template ? 1 : 0

  name = var.launch_template.name
}

locals {
  launch_template = var.launch_template.create ? one(aws_launch_template.lt) : var.launch_template.use_launch_template ? one(data.aws_launch_template.lt) : null
}
