variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "system_vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "system_node_count" {
  type    = number
  default = 1
}

variable "user_vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "user_node_count" {
  type    = number
  default = 1
}

