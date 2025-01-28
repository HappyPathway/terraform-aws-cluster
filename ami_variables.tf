variable "ami" {
  description = "Configuration for the AMI data source"
  type = object({
    most_recent      = optional(bool, true)
    owners           = optional(list(string), ["self"])
    executable_users = optional(list(string), ["self"])
    name_regex       = optional(string, null)
    filters = optional(list(object({
      name   = string
      values = list(string)
    })), [])
  })
  default = {
    most_recent      = false
    owners           = []
    executable_users = []
    name_regex       = null
    filters          = []
  }
}