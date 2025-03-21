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
  ip = "192.168.22.26"
  gateway = "192.168.22.1"
  nameserver = "192.168.22.1"
  searchdomain = "vernify.com"
}

resource "proxmox_vm_qemu" "docker-vm" {
    name = "docker-vm"
    target_node = "pve08"
    vmid = 1114
    desc = "Docker server"
    onboot = true
    clone = "ubuntu-2404-template"
    full_clone = true
    agent = 1
    numa = true
    hotplug = "network,disk,usb,cpu,memory"
    cores = 4
    sockets = 1
    cpu = "host"
    memory = 8192
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
            size = "100G"
            storage = "ceph01"
            format = "raw"
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
    depends_on = [proxmox_vm_qemu.docker-vm]

    provisioner "local-exec" {
        command = <<EOT
        while ! ping -c 1 -W 1 ${local.ip}; do
            sleep 5
        done
        EOT
    }
}

# Install Apps
resource "null_resource" "install_media" {
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
            "sudo apt install -y nfs-common software-properties-common ca-certificates apt-transport-https curl wget git python3-lxml ffmpeg mediainfo p7zip-full unrar unzip python3-pip",
            "sudo mkdir -p /media",
            "echo '192.168.50.210:/volume2/Media /media nfs defaults,nolock 0 0' | sudo tee -a /etc/fstab",
            "sudo systemctl daemon-reload",
            "sudo mount -a"
        ]
    }

    # Install Docker
    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /etc/apt/keyrings",
            "sudo rm -f /etc/apt/keyrings/docker.gpg",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo systemctl daemon-reload",
            "sudo apt update",
            "sudo apt install -y docker-ce docker-ce-cli containerd.io",
            "sudo usermod -aG docker werner",
            "sudo systemctl enable docker",
            "sudo systemctl start docker"
        ]
    }

    # Place Docker compose file
  provisioner "file" {
    source      = local_file.docker_compose.filename
    destination = "/home/werner/docker-compose.yml"
  }
    #provisioner "file" {
    #    source      = "docker-compose.yml"
    #    destination = "/home/werner/docker-compose.yml"
    #}

    # Start stack
    provisioner "remote-exec" {
        inline = [
          "cd /home/werner",
          "docker compose up -d"
        ]
    }
}

resource "local_file" "docker_compose" {
  content  = templatefile("${path.module}/docker-compose.tpl.yml", {
    openvpn_user = var.openvpn_user,
    openvpn_password = var.openvpn_password
  })
  filename = "${path.module}/docker-compose.yml"
}
