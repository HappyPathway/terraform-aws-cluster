resource "random_pet" "project_name" {}

resource "aws_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.cidr_block => subnet }

  vpc_id            = var.vpc_id
  cidr_block        = var.subnets[count.index].cidr_block
  availability_zone = var.subnets[count.index].availability_zone
}

resource "aws_security_group" "security_group" {
  for_each    = { for security_group in var.security_groups : security_group.name => security_group }
  name        = "${var.project_name}-${random_pet.project_name.id}"
  vpc_id      = var.vpc_id
  description = "Stubbed security group for ${var.project_name}"
}

resource "aws_security_group_rule" "ingress" {
  for_each          = { for security_group in var.security_groups : security_group.name => security_group }
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  type              = each.value.type
  security_group_id = aws_security_group.security_group[each.key].id
}

module "autoscaling" {
  source = "../../"

  tags = {
    Environment = var.project_name
  }
  ami = {
    most_recent      = true
    owners           = ["self"]
    executable_users = ["self"]
    name_regex       = "^${var.project_name}-"
    filters = [
      {
        name   = "tag:Name"
        values = ["${var.project_name}-*"]
      }
    ]
  }
  security_group_ids = aws_security_group.security_group[*].id
  project_name       = var.project_name
  instance_type      = "t2.micro"
}
