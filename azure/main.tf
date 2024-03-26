resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "vnet-${var.resource_group_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.224.0.0/12"]

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.resource_group_name}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.224.0.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_kubernetes_cluster" "placeos" {
    name                = "aks-placeos--${var.resource_group_name}-${var.environment}"
    location            = var.location
    resource_group_name = var.resource_group_name
    dns_prefix          = var.dns_prefix


    default_node_pool {
        name            = "agentpool"
        node_count      = 3
        vm_size         = var.environment == "Production" ? "Standard_DS11_v2" : "Standard_D2_v3"
        vnet_subnet_id  = azurerm_subnet.subnet.name
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
