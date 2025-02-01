output "ami" {
  value = data.aws_ami.ami
}

output "cloud_init" {
  value = data.cloudinit_config.cloud_init
}

output "autoscaling_group" {
  value = local.autoscaling_group
}

output "launch_template" {
  value = try(aws_launch_template.test, null)
}

output "subnet" {
  value = try(aws_subnet.test, null)
}

output "placement_group" {
  value = try(aws_placement_group.test, null)
}
