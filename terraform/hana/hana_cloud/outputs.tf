output "service_id" {
  value       = cloudfoundry_service_instance.hana_cloud_hana.id
  description = "The GUID of the service instance."
}