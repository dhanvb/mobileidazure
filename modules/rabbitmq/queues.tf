locals {
  queues = var.cloudamqp_settings.queues
}

resource "rabbitmq_queue" "rabbitmq" {
  for_each = toset(keys({ for key, value in local.queues : key => value }))
  name     = local.queues[each.value].name
  vhost    = local.vhost
  settings {
    durable     = local.queues[each.value].settings.durable
    auto_delete = local.queues[each.value].settings.auto_delete
  }
}