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
  description = "AMI ID for the launch template"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the launch template"
  type        = string
}

variable "key_name" {
  description = "Key name for the launch template"
  type        = string
}

variable "predictive_scaling_metric_specification" {
  description = "Metric specification for the predictive scaling policy"
  type = object({
    target_value = number
    predefined_load_metric_specification = object({
      predefined_metric_type = string
    })
  })
}

variable "security_groups" {
  description = "List of security groups for the auto scaling group"
  type        = list(string)
}
