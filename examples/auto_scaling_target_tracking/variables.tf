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

variable "target_tracking_policy_name" {
  description = "Name of the target tracking policy"
  type        = string
}

variable "target_tracking_metric_type" {
  description = "Type of the predefined metric for target tracking"
  type        = string
}

variable "target_tracking_target_value" {
  description = "Target value for the target tracking policy"
  type        = number
}

variable "security_groups" {
  description = "List of security groups for the auto scaling group"
  type        = list(string)
}
