module "basic_autoscaling" {
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
}
