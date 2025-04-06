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
  ip = "192.168.1.10"
  gateway = "192.168.1.1"
  nameserver = "192.168.1.1"
  searchdomain = "vernify.com"
}

resource "proxmox_vm_qemu" "ics-vpn" {
    name = "ics-vpn"
    target_node = "pve08"
    vmid = 101
    desc = "ICS-Saiciom VPN server"
    onboot = true
    clone = "ubuntu-2404-template"
    full_clone = true
    agent = 1
    numa = true
    hotplug = "network,disk,usb,cpu,memory"
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 4096
    scsihw = "virtio-scsi-pci"
    machine = "q35"
    qemu_os = "other"

    disks {
      ide {
        ide0 {
          cloudinit {
            storage = "local-lvm"
          }
        }
      }
      virtio {
        virtio0 {
          disk {
            size = "10G"
            storage = "local-lvm"
            format = "qcow2"
          }
        }
      }
    }

    network {
      bridge = "vmbr0"
      model  = "virtio"
    }
    ipconfig0 = "ip=${local.ip}/24,gw=${local.gateway}"
    nameserver = "${local.nameserver}"
    searchdomain = "${local.searchdomain}"
    skip_ipv6 = true
    os_type = "cloud-init"
}

resource "null_resource" "wait_for_vm" {
    depends_on = [proxmox_vm_qemu.ics-vpn]

    provisioner "local-exec" {
        command = <<EOT
        while ! ping -c 1 -W 1 ${local.ip}; do
            sleep 5
        done
        EOT
    }
}

# Install Apps
resource "null_resource" "configure_vpn" {
  depends_on = [null_resource.wait_for_vm]

  connection {
    type        = "ssh"
    host        = local.ip
    user        = "werner"
    private_key = file("~/.ssh/id_rsa")
  }

  # Install common packages and configure base system
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install -y software-properties-common ca-certificates curl wget git unzip python3-pip",
        ]
    }

}

