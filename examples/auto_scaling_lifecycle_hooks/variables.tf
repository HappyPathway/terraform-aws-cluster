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

variable "lifecycle_hook_name" {
  description = "Name of the lifecycle hook"
  type        = string
}

variable "lifecycle_transition" {
  description = "Transition for the lifecycle hook"
  type        = string
}

variable "notification_target_arn" {
  description = "ARN of the notification target for the lifecycle hook"
  type        = string
}

variable "role_arn" {
  description = "ARN of the role for the lifecycle hook"
  type        = string
}

variable "notification_metadata" {
  description = "Metadata for the lifecycle hook notification"
  type        = string
  default     = null
}

variable "heartbeat_timeout" {
  description = "Heartbeat timeout for the lifecycle hook"
  type        = number
  default     = 3600
}

variable "default_result" {
  description = "Default result for the lifecycle hook"
  type        = string
  default     = "CONTINUE"
}
