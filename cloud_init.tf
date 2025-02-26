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

locals {
  user_data = data.cloudinit_config.config.rendered
}

data "aws_availability_zone" "current" {
  name = var.launch_template.placement != null ? var.launch_template.placement.availability_zone : null
}