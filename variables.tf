variable "tags" {
  description = "Arbitrary tags that will be applied to all resources created in this module"
  type        = map(string)
}

variable "subnets" {
  description = "List of subnets that the autoscaling group will be deployed to"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs that will be applied to the autoscaling group"
  type        = list(string)
}

variable "project_name" {
  description = "Project name used to find the appropriate AMI for the launch configuration"
  type        = string
}

variable "cloud_init_config" {
  description = "Cloud-init configuration that will be appended to user-data for the launch configuration"
  type = list(object({
    path    = string
    content = string
  }))
  default = []
}

variable "volume_mappings" {
  description = "List of volume mappings that will be applied to the launch configuration"
  type        = list(map(string))
}

variable "instance_type" {
  description = "Instance type that will be used for the launch configuration"
  type        = string
}

variable "key_name" {
  description = "Key name that will be used for the launch configuration"
  type        = string
}

variable "file_list" {
  description = "List of files to be included in the configuration"
  type = list(object({
    filename     = string
    content_type = string
  }))
  default = []
}
# propagate_tags_at_launch
variable "propagate_tags_at_launch" {
  description = "Specifies whether tags are propagated to the instances in the Auto Scaling group"
  type        = bool
  default     = true
}

# min_size
variable "min_size" {
  description = "Minimum size of the autoscaling group"
  type        = number
  default     = 1
}

# max_size
variable "max_size" {
  description = "Maximum size of the autoscaling group"
  type        = number
  default     = 3
}

# desired_capacity
variable "desired_capacity" {
  description = "Desired capacity of the autoscaling group"
  type        = number
  default     = 2
}
