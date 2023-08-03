resource "btp_subaccount_entitlement" "this_service" {
  subaccount_id = var.subaccount_id
  service_name  = var.service_name
  plan_name     = var.service_plan_name
}
