variable "project_name" {
  description = "Project name used to identify resources"
  type        = string
}

variable "min_size" {
  description = "Minimum size of the auto scaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the auto scaling group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the auto scaling group"
  type        = number
}

variable "subnets" {
  description = "List of subnets for the auto scaling group"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the launch configuration"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the launch configuration"
  type        = string
}

variable "key_name" {
  description = "Key name for the launch configuration"
  type        = string
}

variable "scale_up_min_size" {
  description = "Minimum size of the auto scaling group during scale up"
  type        = number
}

variable "scale_up_max_size" {
  description = "Maximum size of the auto scaling group during scale up"
  type        = number
}

variable "scale_up_desired_capacity" {
  description = "Desired capacity of the auto scaling group during scale up"
  type        = number
}

variable "scale_up_recurrence" {
  description = "Recurrence schedule for scaling up"
  type        = string
}

variable "scale_down_min_size" {
  description = "Minimum size of the auto scaling group during scale down"
  type        = number
}

variable "scale_down_max_size" {
  description = "Maximum size of the auto scaling group during scale down"
  type        = number
}

variable "scale_down_desired_capacity" {
  description = "Desired capacity of the auto scaling group during scale down"
  type        = number
}

variable "scale_down_recurrence" {
  description = "Recurrence schedule for scaling down"
  type        = string
}

variable "security_groups" {
  description = "List of security groups for the auto scaling group"
  type        = list(string)
}
