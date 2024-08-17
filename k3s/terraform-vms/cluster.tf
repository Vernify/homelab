terraform {
  required_version = ">= 0.13.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true
}

module "k3s_masters" {
  source = "./vm_module"
  providers = {
    proxmox = proxmox
  }

  vm_count = var.number_k3s_masters
  vm_name_prefix = "k3s-master"
  number_hypervisor_nodes = var.number_hypervisor_nodes
  vmid_start = 301
  clone_template = "ubuntu-2404-template"
  cores = 1
  memory = 2048
  disk_size = "10G"
  ip_base = "192.168.22.3"
  gateway = "192.168.22.1"
  nameserver = "192.168.22.1"
  searchdomain = "vernify.com"
  ssh_user = "werner"
  ssh_private_key = "~/.ssh/id_rsa"
}

module "k3s_nodes" {
  source = "./vm_module"
  providers = {
    proxmox = proxmox
  }

  vm_count = var.number_k3s_nodes
  vm_name_prefix = "k3s-node"
  number_hypervisor_nodes = var.number_hypervisor_nodes
  vmid_start = 401
  clone_template = "ubuntu-2404-template"
  cores = 4
  memory = 8192
  disk_size = "10G"
  ip_base = "192.168.22.4"
  gateway = "192.168.22.1"
  nameserver = "192.168.22.1"
  searchdomain = "vernify.com"
  ssh_user = "werner"
  ssh_private_key = "~/.ssh/id_rsa"
  target_storage = "ceph01"
  depends_on = [module.k3s_masters]
}