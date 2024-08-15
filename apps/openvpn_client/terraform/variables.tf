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
