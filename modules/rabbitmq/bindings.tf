locals {
  bindings = var.cloudamqp_settings.bindings
}

resource "rabbitmq_binding" "rabbitmq" {
  for_each         = toset(keys({ for key, value in local.bindings : key => value }))
  source           = local.bindings[each.value].source
  vhost            = local.vhost
  destination      = local.bindings[each.value].destination
  destination_type = local.bindings[each.value].destination_type
  routing_key      = local.bindings[each.value].routing_key
  depends_on = [
    rabbitmq_exchange.rabbitmq,
    rabbitmq_queue.rabbitmq
  ]
}