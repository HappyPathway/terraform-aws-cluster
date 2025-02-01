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

variable "security_groups" {
  description = "List of security groups for the auto scaling group"
  type        = list(string)
}

variable "scaling_adjustment" {
  description = "Scaling adjustment for the step scaling policy"
  type        = number
}

variable "adjustment_type" {
  description = "Adjustment type for the step scaling policy"
  type        = string
}

variable "cooldown" {
  description = "Cooldown period for the step scaling policy"
  type        = number
}

variable "policy_type" {
  description = "Policy type for the step scaling policy"
  type        = string
}

variable "estimated_instance_warmup" {
  description = "Estimated instance warmup time for the step scaling policy"
  type        = number
}

variable "step_adjustment" {
  description = "Step adjustment configuration for the step scaling policy"
  type = list(object({
    scaling_adjustment          = number
    metric_interval_lower_bound = number
    metric_interval_upper_bound = number
  }))
}
