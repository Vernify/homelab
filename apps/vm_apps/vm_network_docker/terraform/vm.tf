resource "proxmox_vm_qemu" "docker_vm" {
  name        = var.hostname
  target_node = var.target_node
  vmid        = var.vmid
  desc        = "Docker server for network services containers"
  onboot      = true
  hagroup     = "Default"
  hastate     = "started"
  clone       = "ubuntu-2404-template"
  full_clone  = true
  agent       = 1
  numa        = true
  hotplug     = "network,disk,usb,cpu,memory"
  cores       = var.cores
  sockets     = 1
  cpu         = "host"
  memory      = var.memory
  scsihw      = "virtio-scsi-pci"
  machine     = "q35"
  qemu_os     = "other"

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "syn05"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = "50G"
          storage = "syn05"
          format  = "raw"
          cache   = "writeback"
          discard = true
        }
      }
      virtio1 {
        disk {
          size    = "50G"
          storage = "syn05"
          format  = "raw"
          cache   = "writeback"
          discard = true
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  ipconfig0    = "ip=${var.ip}/24,gw=${var.gateway}"
  nameserver   = var.nameserver
  searchdomain = var.searchdomain
  skip_ipv6    = true

  os_type = "cloud-init"
}

# SSH readiness check moved to Ansible as first task
# This allows for better error handling and cleaner separation of concerns

# resource "null_resource" "install_application" {
#   depends_on = [null_resource.wait_for_vm]
# 
#   connection {
#     type        = "ssh"
#     host        = var.ip
#     user        = "werner"
#     private_key = file("~/.ssh/id_rsa")
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt update",
#       "sudo apt install git vim apt-transport-https ca-certificates curl software-properties-common -y",
#       "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
#       "sudo add-apt-repository -y \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
#       "sudo apt install -y docker-ce docker-ce-cli containerd.io",
#       "sudo systemctl enable docker",
#       "sudo systemctl start docker",
#     ]
#   }
# 
# }
