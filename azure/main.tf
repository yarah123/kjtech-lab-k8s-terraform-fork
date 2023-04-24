provider "azurerm" {
  version = "~> 2.92.0"
  features {}
  #skip_provider_registration = true
}

provider "random"{ version = "~> 2.3.0"}

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
        vm_size         = "Standard_D2_v3"
    }

    identity {
      type = "SystemAssigned"
    }

    network_profile {
      load_balancer_sku = "Standard"
      network_plugin = "kubenet"
      network_policy = "calico"
    }

    tags = {
        Environment = "Production"
    }
}
