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

variable "saicom_endpoint" {
    type        = string
}

variable "saicom_port" {
    type        = number
}

variable "saicom_username" {
    type        = string
}

variable "saicom_password" {
    type        = string
}

variable "iotel_endpoint" {
    type        = string
}

variable "iotel_port" {
    type        = number
}

variable "iotel_username" {
    type        = string
}

variable "iotel_password" {
    type        = string
}