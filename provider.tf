
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}


provider "kubernetes" {
  host                   = module.aks_dev.host
  client_certificate     = base64decode(module.aks_dev.client_certificate)
  client_key             = base64decode(module.aks_dev.client_key)
  cluster_ca_certificate = base64decode(module.aks_dev.cluster_ca_certificate)
}