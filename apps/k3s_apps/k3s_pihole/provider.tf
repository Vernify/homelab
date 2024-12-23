# Terraform to provision a LXC VM in Proxmox, and deploy an OpenPVN client
# This will be used as a gateway to connect to the OpenVPN server

terraform {
    required_version = ">= 0.13.0"

    required_providers {
      proxmox = {
        source  = "telmate/proxmox"
        version = "3.0.1-rc3"
      }
    }
}
