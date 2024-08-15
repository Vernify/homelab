# vm_module/main.tf
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  count = var.vm_count

  name = "${var.vm_name_prefix}-${count.index + 1}"
  target_node = "pve0${(count.index % var.number_hypervisor_nodes) + 1}"
  vmid = var.vmid_start + count.index
  desc = "${var.vm_name_prefix} ${count.index + 1}"

  onboot = true
  clone = var.clone_template
  full_clone = true

  agent = 1
  numa = true
  hotplug = "network,disk,usb,cpu,memory"

  cores = var.cores
  sockets = 1
  cpu = "host"

  memory = var.memory

  bootdisk = "virtio0"
  scsihw = "virtio-scsi-pci"

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.target_storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size = var.disk_size
          storage = var.target_storage
          format = "raw"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  ipconfig0 = "ip=${var.ip_base}${count.index + 1}/24,gw=${var.gateway}"
  nameserver = var.nameserver
  searchdomain = var.searchdomain
  skip_ipv6 = true

  os_type = "cloud-init"

  provisioner "remote-exec" {
    inline = [
      "while [ $(cloud-init status | grep -c 'status: done') -eq 0 ]; do sleep 5; done",
      "sudo apt update",
      "sudo apt install -y nfs-common",
      "sudo reboot"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = split("/", split(",", split("=", self.ipconfig0)[1])[0])[0]
      agent       = false
    }
  }
}