data "aws_ami" "ami" {
  most_recent      = var.ami.most_recent
  owners           = var.ami.owners
  executable_users = var.ami.executable_users
  name_regex       = var.ami.name_regex
  dynamic "filter" {
    for_each = var.ami.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}