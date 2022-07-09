
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.39.0"
    }
  }
}

provider "azurerm" {
  features {}
  
subscription_id = "6639734e-66ce-4540-adc9-62b2465bcc4c"
client_id       = "178eae0e-1900-4960-a83d-b264d7b54410"
client_secret   = "GNy8Q~Li0DT0QZW2gxETE05ENAzTSE.xFisUBdme"
tenant_id       = "f23a8f4c-9582-4d7c-918e-7548eaa466e5"
}

resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet" 
  }
}
