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

variable "number_k3s_masters" {
  description = "Number of K3S master nodes"
  type        = number
  default     = 3
}

variable "number_k3s_nodes" {
  description = "Number of K3S worker nodes"
  type        = number
  default     = 4
}

variable "number_hypervisor_nodes" { 
  description = "Number of hypervisor nodes available"
  type        = number
  default     = 1
}
