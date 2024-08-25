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
  name = "${var.name_prefix}-${count.index + 1}"
  target_node = "pve0${(count.index % var.number_hypervisor_nodes) + 1}"
  vmid = var.vmid_base + count.index
  desc = "${var.description} ${count.index + 1}"
  onboot = true
  clone = var.clone_template
  full_clone = true
  agent = 1
  numa = true
  hotplug = "network,disk,usb,cpu,memory"
  timeouts {
    create = "30m"
  }

  cores = var.cores
  sockets = 1
  cpu = "host"
  memory = var.memory
  scsihw = "virtio-scsi-pci"
  machine = "q35"
  qemu_os = "other"

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.cloudinit_storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size = var.disk_size
          storage = var.disk_storage
          format = var.disk_format
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  ipconfig0 = "ip=192.168.22.${var.ip_base + count.index}/24,gw=${var.gateway}"
  nameserver = var.nameserver
  searchdomain = var.searchdomain
  skip_ipv6 = true

  os_type = "cloud-init"

  provisioner "remote-exec" {
    inline = var.provisioner_inline

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = split("/", split(",", split("=", self.ipconfig0)[1])[0])[0]
      agent       = false
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}