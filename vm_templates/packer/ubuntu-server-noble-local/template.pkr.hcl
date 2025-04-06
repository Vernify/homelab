# Ubuntu Server Noble Numbat
# ---
# Packer Template to create an Ubuntu Server 24.04 LTS (Noble Numbat) on Proxmox
variable "proxmox_api_url" {
  type    = string
  default = "{{ env \"PROXMOX_API_URL\" }}"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "{{ env \"PROXMOX_API_TOKEN_ID\" }}"
}

variable "proxmox_api_token_secret" {
  type    = string
  default = "{{ env \"PROXMOX_API_TOKEN_SECRET\" }}"
}

variable "ssh_password" {
  type    = string
  default = "{{ env \"PROXMOX_SSH_PASSWORD\" }}"
}

variable "ssh_private_key_file" {
  type    = string
  default = "{{ env \"PROXMOX_SSH_PRIVATE_KEY_FILE\" }}"
}

variable "node" {
  type    = string
  default = "{{ env \"PROXMOX_NODE\" }}"
}

variable "template_storage" {
  type    = string
  default = "syn05"
}

variable "build_date" {
  type    = string
  default = "{{ env `build_date` }}" 
}

# Packer Plugin Definition
packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Proxmox VM Source
source "proxmox-iso" "ubuntu-server-noble-numbat" {
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    node = "${var.node}"

    insecure_skip_tls_verify = true

    vm_id = "24${replace(var.build_date, "-", "")}"
    template_description = "Noble Numbat"
    vm_name               = "ubuntu-server-noble-numbat-${var.build_date}"
    template_name         = "ubuntu-2404-template-${var.build_date}"

    iso_file = "syn05:iso/ubuntu-24.04-live-server-amd64.iso"
    iso_storage_pool = "syn05"

    unmount_iso = true

    qemu_agent = true
    machine = "q35"

    scsi_controller = "virtio-scsi-pci"
    cores = "2"
    memory = "4096"

    ssh_username = "root"  # <-- Add this line

    disks {
        disk_size = "10G"
        format = "qcow2"
        storage_pool = "${var.template_storage}"
        type = "virtio"
    }

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
    }

    cloud_init = true
    cloud_init_storage_pool = "${var.template_storage}"
}


build {
  sources = ["source.proxmox-iso.ubuntu-server-noble-numbat"]

  provisioner "file" {
    source      = "cloud-init/"
    destination = "/var/lib/cloud/seed/nocloud/"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",
      "sudo cloud-init clean",
      "sudo cloud-init status --wait",
      "sudo cloud-init init",
      "sudo cloud-init modules --mode=config",
      "sudo cloud-init modules --mode=final"
    ]
  }

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean --machine-id",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }
}
