locals {
  uuid = uuid()
}

###
# Creation of subaccount
###
resource "btp_subaccount" "project" {
  name      = "${var.subaccount_name} - ${var.repo_name}"
  subdomain = local.uuid
  region    = lower("${var.region}")
}

###
# Assignment of emergency admins to the sub account as sub account administrators
###
resource "btp_subaccount_role_collection_assignment" "subaccount_users" {
  for_each = toset("${var.app_admins}")
    subaccount_id        = btp_subaccount.project.id
    role_collection_name = "Subaccount Administrator"
    user_name            = each.value
}

###
# Creation of Cloud Foundry environment
###
module "cloudfoundry_environment" {
  source = "github.com/SAP-samples/btp-terraform-samples/released/modules/envinstance-cloudfoundry/"

  subaccount_id         = btp_subaccount.project.id
  instance_name         = replace(local.uuid, "-", "")
  cloudfoundry_org_name = replace(local.uuid, "-", "")
}

###
# Create Cloud Foundry space and assign users
###
module "cloudfoundry_space" {
  source = "github.com/SAP-samples/btp-terraform-samples/released/modules/cloudfoundry-space/"
  cf_org_id           = module.cloudfoundry_environment.org_id
  name                = "development"
  cf_space_managers   = var.app_admins
  cf_space_developers = var.app_admins
  cf_space_auditors   = var.app_admins
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}
