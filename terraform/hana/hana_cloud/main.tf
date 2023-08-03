data "cloudfoundry_service" "hana_cloud" {
  name = "hana-cloud"
}

resource "cloudfoundry_service_instance" "hana_cloud_hana" {
  name         = "hana-cloud"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service.hana_cloud.service_plans["hana"]
  json_params  = jsonencode({"data": {"memory": 30,"edition": "cloud","systempassword": "Abcd1234", "whitelistIPs": ["0.0.0.0/0"]}})
}
