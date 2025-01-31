variable "project_name" {
  description = "Project name used to find the appropriate AMI for the launch configuration"
  type        = string
  default     = "example-project"
}

variable "security_groups" {
  type = list(object({
    name                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    type                     = string
    cidr_blocks              = list(string)
    ipv6_cidr_blocks         = list(string)
    prefix_list_ids          = list(string)
    self                     = optional(bool, null)
    source_security_group_id = optional(string, null)
  }))
  default = [
    {
      name                     = "default-sg"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      type                     = "ingress"
      cidr_blocks              = ["0.0.0.0/0"]
      ipv6_cidr_blocks         = []
      prefix_list_ids          = []
      source_security_group_id = null
    }
  ]
}

variable "vpc_id" {
  description = "The ID of the VPC where the subnets will be created"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the instances will be launched"
  type        = string
}