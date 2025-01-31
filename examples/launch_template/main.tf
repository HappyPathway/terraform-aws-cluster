resource "random_pet" "project_name" {}

resource "aws_security_group" "security_group" {
  for_each    = { for security_group in var.security_groups : security_group.name => security_group }
  name        = "${var.project_name}-${random_pet.project_name.id}"
  vpc_id      = var.vpc_id
  description = "Stubbed security group for ${var.project_name}"
}

resource "aws_security_group_rule" "ingress" {
  for_each                 = { for security_group in var.security_groups : security_group.name => security_group }
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  type                     = each.value.type
  security_group_id        = aws_security_group.security_group[each.key].id
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  source_security_group_id = each.value.source_security_group_id
}



module "autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent = true
    owners      = ["self"]
    filters = [
      {
        name   = "tag:Project"
        values = ["${var.project_name}"]
      }
    ]
  }
  security_group_ids = [for sec_group in var.security_groups : lookup(aws_security_group.security_group, sec_group.name).id]
  project_name       = var.project_name
  instance_type      = "t2.micro"
  launch_template = {
    key_name            = "example-key"
    use_launch_template = true
    create              = true
    network_interfaces = [{
      associate_public_ip_address = true
      subnet_id                   = var.subnet_id
    }]
  }
}
