module "cloudamqp" {
  source             = "../../modules/cloudamqp"
  client             = local.config.client
  environment        = var.environments[(length(var.environments) - 1)]
  cloudamqp_apikey   = var.cloudamqp_apikey
  cloudamq_region    = local.config.cloudamq_region
  cloudamq_instances = local.config.cloudamq_instances
}

module "rabbitmq" {
  source                           = "../../modules/rabbitmq"
  cloudamqp_endpoint               = var.cloudamqp_endpoint
  cloudamqp_credentials            = module.cloudamqp.cloudamqp_intance_credentials
  cloudamqp_settings               = local.cloudamqp_settings
  cloudamqp_instance_provider_data = module.cloudamqp.cloudamqp_instance_provider_data
  environment                      = var.environments[(length(var.environments) - 1)]
}
