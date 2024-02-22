output "broker_instance_provider_url" {
  value     = module.cloudamqp.cloudamqp_instance_provider_url
  sensitive = true
}