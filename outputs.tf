output "ami" {
  value = data.aws_ami.ami
}

output "cloud_init" {
  value = data.cloudinit_config.cloud_init
}

output "autoscaling_group" {
  value = local.autoscaling_group
}
