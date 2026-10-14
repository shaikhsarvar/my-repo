variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "firewall_subnet_id" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "firewall_name" {
  type = string
}
variable "firewall_policy_id" {
  description = "Azure Firewall Policy ID"
  type        = string
}