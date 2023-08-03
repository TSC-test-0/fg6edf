data "cloudfoundry_service" "hana" {
  name = "hana"
}

resource "cloudfoundry_service_instance" "hana_hdi_shared" {
  name         = "hana"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service.hana.service_plans["hdi-shared"]
}