terraform {
  required_providers {
    azurerm = {
      version = "~> 3.44.1"
    }
    random = {
      version = "~> 2.3.0"
    }
  }
}

provider "azurerm" {
  features {}
  #skip_provider_registration = true
}

provider "random" { }

