data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init.yaml", {
      parameter_prefix = var.parameter_prefix
      secrets_prefix   = var.secrets_prefix
    })
  }
}

data "cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      write_files = var.cloud_init_config
    })
  }
}

locals {
  user_data = data.cloudinit_config.config.rendered
}
