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

variable "warm_pool_instance_reuse_policy" {
  description = "Instance reuse policy for the warm pool"
  type = object({
    reuse_on_scale_in = bool
  })
}

variable "warm_pool_max_group_prepared_capacity" {
  description = "Maximum group prepared capacity for the warm pool"
  type        = number
}

variable "warm_pool_min_size" {
  description = "Minimum size for the warm pool"
  type        = number
}

variable "warm_pool_pool_state" {
  description = "Pool state for the warm pool"
  type        = string
}

variable "security_groups" {
  description = "List of security groups for the auto scaling group"
  type        = list(string)
}
