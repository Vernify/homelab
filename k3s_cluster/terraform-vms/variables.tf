# variables.tf
variable "proxmox_api_url" {
    description = "The URL of the Proxmox API"
    type        = string
}

variable "proxmox_api_token_id" {
    description = "The username to authenticate with the Proxmox API"
    type        = string
    sensitive   = true
}

variable "proxmox_api_token_secret" {
    description = "The password to authenticate with the Proxmox API"
    type        = string
    sensitive   = true
}

variable "number_hypervisor_nodes" {
  type = number
  default = 3
}

#variable "number_k3s_masters" {
#  type = number
#  default = 3
#}
#
#variable "number_k3s_nodes" {
#  type = number
#  default = 3
#}
