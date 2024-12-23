# cluster.tf
terraform {
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

locals {
  master_ips = [31, 32, 33]
  node_ips = [35, 36, 37]
  gateway = "192.168.22.1"
  nameserver = "192.168.22.1"
  searchdomain = "vernify.com"
  template = "ubuntu-2404-template"
}

module "masters" {
  source = "./vm_module"

  vm_count = 3
  name_prefix = "k3s-master"
  number_hypervisor_nodes = var.number_hypervisor_nodes
  vmid_base = 301
  description = "Master Node"
  clone_template = local.template
  cores = 1
  memory = 2048
  cloudinit_storage = "local-lvm"
  disk_size = "10G"
  disk_storage = "local-lvm"
  disk_format = "raw"
  ip_base = local.master_ips[0]
  gateway = local.gateway
  nameserver = local.nameserver
  searchdomain = local.searchdomain
  ssh_user = "werner"
  ssh_private_key = "~/.ssh/id_rsa"
  provisioner_inline = [
    "sudo reboot"
  ]
}

module "nodes" {
  source = "./vm_module"

  vm_count = 3
  name_prefix = "k3s-node"
  number_hypervisor_nodes = var.number_hypervisor_nodes
  vmid_base = 401
  description = "Node"
  clone_template = local.template
  cores = 4
  memory = 8192
  cloudinit_storage = "local-lvm"
  disk_size = "30G"
  disk_storage = "ceph01"
  disk_format = "raw"
  ip_base = local.node_ips[0]
  gateway = local.gateway
  nameserver = local.nameserver
  searchdomain = local.searchdomain
  ssh_user = "werner"
  ssh_private_key = "~/.ssh/id_rsa"
  provisioner_inline = [
    "while [ $(cloud-init status | grep -c 'status: done') -eq 0 ]; do echo 'Waiting on cloud-init'; sleep 5; done",
    "sudo apt update",
    "sudo apt install -y nfs-common",
    "sudo reboot"
  ]
}

output "masters" {
  value = module.masters
}

output "nodes" {
  value = module.nodes
}
