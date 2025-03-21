variable "proxmox_api_url" {
    description = "The URL of the Proxmox API"
    type        = string
}

variable "proxmox_api_token_id" {
    description = "The username to authenticate with the Proxmox API"
    type        = string
    #sensitive   = true
}

variable "proxmox_api_token_secret" {
    description = "The password to authenticate with the Proxmox API"
    type        = string
    #sensitive   = true
}

variable "ip" {
  description = "IP address for the LXC container"
  type        = string
}

variable "gateway" {
  description = "Gateway for the LXC container"
  type        = string
}

variable "nameserver" {
  description = "Nameserver for the LXC container"
  type        = string
}

variable "searchdomain" {
  description = "Search domain for the LXC container"
  type        = string
}

variable "vmid" {
  description = "VM ID for the LXC container"
  type        = number
}

variable "target_node" {
  description = "Target node for the LXC container"
  type        = string
}

variable "disk" {
  description = "Target disk size for the LXC container"
  type        = string
}

variable "hostname" {
  description = "Hostname for the LXC container"
  type        = string
}

variable "memory" {
  description = "Memory for the LXC container"
  type        = string
}

variable "cores" {
  description = "Number of VM cores"
  type        = number
}