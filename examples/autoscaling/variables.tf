variable "project_name" {
  description = "Project name used to find the appropriate AMI for the launch configuration"
  type        = string
  default     = "example-project"
}

variable "security_groups" {
  description = "List of security groups that will be applied to the autoscaling group"
  type = list(object({
    name      = string
    from_port = number
    to_port   = number
    protocol  = string
    type      = string
  }))
  default = [
    {
      name      = "example-sg"
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      type      = "ingress"
    }
  ]
}

variable "subnets" {
  description = "List of subnets that the autoscaling group will be deployed to"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = [
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-west-2a"
    },
    {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-west-2b"
    }
  ]
}

variable "vpc_id" {
  description = "The ID of the VPC where the subnets will be created"
  type        = string
  default     = "vpc-12345678"
}
