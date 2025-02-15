resource "azurerm_resource_group" "this" {
    name = var.resource_group_name
    location = var.azure_region
  
}

resource "azurerm_virtual_network" "this" {
    name = "${var.cluster_name}-vnet"
    resource_group_name = azurerm_resource_group.this.name
    location = azurerm_resource_group.this.location
    address_space = var.vnet_address_space

    tags = {
        Environment = "Demo"
        Name = var.cluster_name
    }
  
}

resource "azurerm_subnet" "this" {
    count = length(var.subnet_address_prefixes)
    name = "${var.cluster_name}-subnet-${count.index}"
    resource_group_name = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes = [var.subnet_address_prefixes[count.index]]
}

resource "azurerm_kubernetes_cluster" "this" {
    name = var.cluster_name
    location = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name
    dns_prefix = var.cluster_name

    default_node_pool {
        name = "defgault"
        node_count = var.node_count
        vm_size = var.node_size
        vnet_subnet_id = element(azurerm_subnet.this[*].id, 0)
    }
    identity {
        type = "SystemAssigned"
    }
    network_profile {
        network_plugin = "azure"
        network_policy = "calico"
    }

    tags = {
        Environment = "Demo"
        Name = var.cluster_name
    }
}

output "cluster_name"{
    value = azurerm_kubernetes_cluster.this.name

}

output "host" {
    value = azurerm_kubernetes_cluster.this.kube_config.0.host
    sensitive = true
}
output "client_certificate" {
    value = azurerm_kubernetes_cluster.this.kube_config.0.client_certificate
    sensitive = true
}

output "client_key" {
    value = azurerm_kubernetes_cluster.this.kube_config.0.client_key
     sensitive = true
}
output "cluster_ca_certificate" {
    value = azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate
     sensitive = true
  
}