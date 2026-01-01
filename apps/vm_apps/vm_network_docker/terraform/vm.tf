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

resource "null_resource" "wait_for_vm" {
  depends_on = [proxmox_vm_qemu.docker_vm]

  provisioner "local-exec" {
    command = <<EOT
    while ! ping -c 1 -W 1 ${var.ip}; do
        sleep 5
    done
    EOT
  }
}

resource "null_resource" "install_application" {
  depends_on = [null_resource.wait_for_vm]

  connection {
    type        = "ssh"
    host        = var.ip
    user        = "werner"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install git vim apt-transport-https ca-certificates curl software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository -y \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt install -y docker-ce docker-ce-cli containerd.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt",
      "if [ ! -d netbox ]; then sudo git clone -b release https://github.com/netbox-community/netbox-docker.git netbox; fi",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/docker-compose.override.yml"
    destination = "/tmp/docker-compose.override.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/docker-compose.override.yml /opt/netbox/docker-compose.override.yml",
      "echo 'Starting Netbox container'",
      "cd /opt/netbox",
      "sudo docker compose pull",
      "sudo docker compose up -d",
    ]
  }

}
