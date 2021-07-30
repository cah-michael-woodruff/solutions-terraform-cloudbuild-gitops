terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.67.0"
    }
  }
}

locals {
  enterprise    = var.enterprise_rule == true ? "e" : "a"
  vpc_name_list = split("-", var.vpc_name)
  vpc_name      = local.vpc_name_list[length(local.vpc_name_list) - 1]
  target_sa     = ""
}
resource "google_compute_firewall" "firewall_module_rule" {
  for_each = { for i, v in var.firewall_rules : i => v }
  project  = var.project
  network  = var.vpc_name


  // [ent/app][ingress/egress][allow/deny] - [VPC suffix] - [target service account name/tag name] - [if different from target sa add source service account] - [opt: purpose]
  name        = "${local.enterprise}${each.value.ingress == true ? "i" : "e"}${length(each.value.allow) > 0 ? "a" : "d"}-${local.vpc_name}-${length(each.value.target_service_account) > 0 ? split("@", each.value.target_service_account)[0] : ""}"
  description = each.value.description
  direction   = each.value.ingress == true ? "INGRESS" : "EGRESS"
  priority    = each.value.priority

  dynamic "log_config" {
    for_each = each.value.enable_logging == true ? [1] : [0]
    content {
      metadata = each.value.enable_log_metadata == true ? "INCLUDE_ALL_METADATA" : "EXCLUDE_ALL_METADATA"
    }
  }

  dynamic "allow" {
    for_each = { for k, v in each.value.allow : k => v }
    content {
      protocol = allow.value["protocol"]
      ports    = allow.value["ports"]
    }
  }
  dynamic "deny" {
    for_each = { for k, v in each.value.deny : k => v }
    content {
      protocol = deny.value["protocol"]
      ports    = deny.value["ports"]
    }
  }

  source_ranges           = each.value.ingress == true ? each.value.ingress_rules.source_ranges : null
  source_service_accounts = each.value.ingress == true ? each.value.ingress_rules.source_service_accounts : null
  source_tags             = each.value.ingress == true && length(each.value.ingress_rules.source_service_accounts) == 0 ? each.value.ingress_rules.source_service_accounts : null

  destination_ranges      = each.value.ingress == true ? null : each.value.egress_rules.dest_ranges
  target_service_accounts = [each.value.target_service_account]
  target_tags             = local.enterprise == true ? each.value.target_tags : null

}
