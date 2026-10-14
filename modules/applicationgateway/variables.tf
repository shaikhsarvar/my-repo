variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "application_gateway_name" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "vm1_private_ip" {
  description = "Private IP of Spoke VM1"
  type        = string
}

variable "vm2_private_ip" {
  description = "Private IP of Spoke VM2"
  type        = string
}