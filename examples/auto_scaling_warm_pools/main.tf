resource "random_pet" "project_name" {}

resource "aws_security_group" "security_group" {
  for_each    = { for security_group in var.security_groups : security_group.name => security_group }
  name        = "${var.project_name}-${random_pet.project_name.id}"
  vpc_id      = "vpc-056336e21941b332a"
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
    owners      = ["099720109477"]
    filters = [
      {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
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
      subnet_id                   = "subnet-0038fa2a217039c178"
    }]
  }
  auto_scaling = {
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
    subnets          = ["subnet-0038fa2a217039c178"]
    warm_pool = {
      instance_reuse_policy = {
        reuse_on_scale_in = true
      }
      max_group_prepared_capacity = 2
      min_size                    = 1
      pool_state                  = "Stopped"
    }
  }
}
