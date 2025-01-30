output "ami" {
  value = data.aws_ami.ami
}

output "launch_configuration" {
  value = local.launch_configuration
}

output "cloud_init" {
  value = data.cloudinit_config.cloud_init
}

output "autoscaling_group" {
  value = aws_autoscaling_group.asg
}
