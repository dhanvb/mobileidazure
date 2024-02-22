locals {
  exchanges = var.cloudamqp_settings.exchanges
}

resource "rabbitmq_exchange" "rabbitmq" {
  for_each = toset(keys({ for key, value in local.exchanges : key => value }))
  name     = local.exchanges[each.value].name
  vhost    = local.vhost
  settings {
    type        = local.exchanges[each.value].settings.type
    durable     = local.exchanges[each.value].settings.durable
    auto_delete = local.exchanges[each.value].settings.auto_delete
  }
}