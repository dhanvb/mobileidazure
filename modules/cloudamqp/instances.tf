locals {
  instances = flatten([
    for instance in var.cloudamq_instances : instance if instance.env == var.environment
  ])
}

resource "cloudamqp_instance" "instances" {
  for_each = toset(keys({ for key, value in local.instances : key => value }))
  name     = "${var.client}-mobileid-${var.cloudamq_instances[each.value].env}"
  plan     = var.cloudamq_instances[each.value].plan
  region   = var.cloudamq_region
  tags     = [var.client, var.environment]
}

data "cloudamqp_credentials" "credentials" {
  for_each    = toset(keys({ for key, value in cloudamqp_instance.instances : key => value }))
  instance_id = cloudamqp_instance.instances[each.value].id
}