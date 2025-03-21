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
  default = "ceph-prov"
}

# Resource Definition for the VM Template
packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu-server-noble-numbat" {
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    node = "${var.node}"

    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    vm_id = "901"
    vm_name = "ubuntu-server-noble-numbat"
    template_description = "Noble Numbat"

    # VM OS Settings
    iso_file = "local:iso/ubuntu-24.04-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso = true
    template_name = "ubuntu-2404-template"

    # VM System Settings
    qemu_agent = true
    machine = "q35"

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "10G"
        #format = "raw"
        format = "qcow2"
        storage_pool = "${var.template_storage}"
        type = "virtio"
    }

    # VM CPU Settings
    cores = "1"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        #firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.template_storage}"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]

    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "./http" 

    ssh_username = "werner"
    ssh_password = "${var.ssh_password}"
    ssh_private_key_file = "${var.ssh_private_key_file}"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-noble-numbat"
    sources = ["proxmox-iso.ubuntu-server-noble-numbat"]

    # Install and enable QEMU Guest Agent
    provisioner "shell" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y qemu-guest-agent",
            "sudo systemctl start qemu-guest-agent",
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
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

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}

