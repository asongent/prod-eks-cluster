provider "aws" {
  region = var.bootstrap_region
}

module "bootstrap" {
  source    = "../../modules/bootstrap"
  account   = var.bootstrap_account
  region    = var.bootstrap_region
  tag_email = var.email
  tag_name  = var.name
}