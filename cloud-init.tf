data "cloudinit_config" "cloud_init" {
  count         = local.cloud_init_parts > 0 ? 1 : 0
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

locals {
  cloud_init_parts = length(concat(var.cloud_init_config, var.file_list))
  cloud_init       = local.cloud_init_parts > 0 ? data.cloudinit_config.cloud_init[0].rendered : null
}