variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "gateway_subnet_id" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "vpn_gateway_name" {
  type = string
}

variable "vpn_shared_key" {
  type      = string
  sensitive = true
}