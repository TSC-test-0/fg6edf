output "service_id" {
  value       = cloudfoundry_service_instance.hana_hdi_shared.id
  description = "The GUID of the service instance."
}