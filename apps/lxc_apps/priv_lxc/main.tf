# Terraform to provision a LXC VM in Proxmox.
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

resource "proxmox_lxc" "vernify_lxc_container" {
  vmid          = var.vmid
  target_node   = var.target_node
  hostname      = var.hostname
  ostemplate    = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password      = base64encode(var.vmid)
  onboot        = true
  start         = true
  hastate       = "started"
  hagroup       = "Default"
  memory        = var.memory
  searchdomain  = var.searchdomain
  nameserver    = var.nameserver
  ssh_public_keys = file("~/.ssh/id_rsa.pub")
  unprivileged  = true

  rootfs {
    storage = "ceph01"
    size    = var.disk
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${var.ip}/24"
    ip6    = "manual"
    gw     = var.gateway
  }

  features {
    nesting = true
  }
}

resource "null_resource" "wait_for_vm" {
  depends_on = [proxmox_lxc.vernify_lxc_container]

  connection {
    type        = "ssh"
    host        = var.ip
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "local-exec" {
    command = <<EOT
    while ! ping -c 1 -W 1 ${replace(proxmox_lxc.vernify_lxc_container.network.0.ip, "/24", "")}; do
        sleep 5
    done
    EOT
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl stop apparmor",
      "systemctl disable apparmor",
      "apt remove --assume-yes --purge apparmor",
      "echo 'Package: apparmor*' | sudo tee /etc/apt/preferences.d/disable-apparmor",
      "echo 'Pin: release *' | sudo tee -a /etc/apt/preferences.d/disable-apparmor",
      "echo 'Pin-Priority: -1' | sudo tee -a /etc/apt/preferences.d/disable-apparmor",
      "systemctl mask apparmor",
      "apt install git vim docker.io docker-compose -y",
      "cd /opt",
      "git clone -b release https://github.com/netbox-community/netbox-docker.git netbox",
      ]
  }

  provisioner "file" {
    source      = "${path.module}/docker-compose.override.yml"
    destination = "/opt/netbox/docker-compose.override.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/netbox",
      "cd netbox",
      "docker-compose up -d",
    ]
  }

}

