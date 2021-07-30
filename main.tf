terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.67.0"
    }
  }
}

provider "google" {}

module "gcp-firewall" {
  source   = "./modules/firewall"
  project  = "edhTest"
  vpc_name = "default"
  firewall_rules = [
    {
      description : "gcp firewall module test - ingress",
      purpose : "test from cloud build and terraform"
      ingress : true,
      priority : 1000,
      enable_logging : true,
      enable_log_metadata : false,
      target_tags            = []
      target_service_account = "sa-servicenow-edhtest01@electric-folio-185219.iam.gserviceaccount.com"
      ingress_rules : {
        source_ranges : ["10.0.0.0/8"],
        source_tags : [],
        source_service_accounts : ["sa-servicenow-edhtest01@electric-folio-185219.iam.gserviceaccount.com"]
      },
      egress_rules : {
        dest_ranges : [],
      },

      allow : [{ protocol : "TCP", ports : ["8080", "443", "8000-8010"] }],
      deny : []
    }
  ]

}
