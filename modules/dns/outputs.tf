output "dns_zone_ingress_ids" {
  value = { for env, ingress in azurerm_dns_zone.ingress : env => ingress.id }
}

output "ingress_resource_group_name" {
  value = [for ingress in azurerm_dns_zone.ingress : ingress.resource_group_name]
}

output "kubernetes_cluster_ip" {
  value = module.cluster.kubernetes_cluster_ip
}