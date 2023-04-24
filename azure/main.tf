resource "random_id" "unique" {
  byte_length = 4
}

resource "azurerm_kubernetes_cluster" "placeos" {
    name                = "aks-placeos--${random_id.unique.hex}"
    location            = var.location
    resource_group_name = var.resource_group_name
    dns_prefix          = var.dns_prefix


    default_node_pool {
        name            = "agentpool"
        node_count      = 3
        vm_size         = var.environment == "Production" ? "Standard_DS11_v2" : "Standard_D2_v3"
    }

    identity {
      type = "SystemAssigned"
    }

    network_profile {
      load_balancer_sku = "standard"
      network_plugin = "kubenet"
      network_policy = "calico"
    }

    tags = {
        Environment = var.environment
    }
}
