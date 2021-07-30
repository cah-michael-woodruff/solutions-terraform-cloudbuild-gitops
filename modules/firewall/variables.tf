variable "project" {
  type    = string
  default = "default"
}

variable "vpc_name" {
  type    = string
  default = "default"
}
variable "enterprise_rule" {
  type    = bool
  default = false
}


variable "firewall_rules" {
  description = "a firewall rule"
  type = list(object({
    description         = string
    purpose             = string
    ingress             = bool
    priority            = number
    enable_logging      = bool
    enable_log_metadata = bool

    target_tags            = list(string)
    target_service_account = string

    ingress_rules = object({
      source_ranges           = list(string)
      source_tags             = list(string)
      source_service_accounts = list(string)
    })

    egress_rules = object({
      dest_ranges = list(string)
    })

    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}
