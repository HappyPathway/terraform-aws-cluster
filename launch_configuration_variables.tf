variable "launch_configuration" {
  description = "Configuration for the launch configuration"
  type = object({
    project_name                 = string
    iam_instance_profile         = optional(string, null)
    instance_type                = string
    associate_public_ip_address  = optional(bool, false)
    placement_tenancy            = optional(string, "default")
    key_name                     = optional(string, null)
    security_group_ids           = optional(list(string), [])
    enable_monitoring            = optional(bool, false)
    ebs_optimized                = optional(bool, false)
    metadata_options             = optional(object({
      http_tokens                 = optional(string, "optional")
      http_put_response_hop_limit = optional(number, 1)
      http_endpoint               = optional(string, "enabled")
    }), {})
  })
  default = {
    project_name                 = "my-project"
    instance_type                = "t2.micro"
  }
}