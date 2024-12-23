variable "vmid" {
  default = 2205
}

locals {
  ip = "192.168.22.5"
  gateway = "192.168.22.1"
  nameserver = "192.168.22.1"
  searchdomain = "vernify.com"
}

resource "proxmox_lxc" "network_docker" {
  vmid          = var.vmid
  target_node   = "pve08"
  hostname      = "network_docker"
  ostemplate    = "local:vztmpl/ubuntu-22.04-1_amd64.tar.zst"
  password      = base64encode(var.vmid)
  unprivileged  = true
  onboot        = true
  start         = true
  hastate       = "started"
  hagroup       = "Default"
  memory        = "4096"
  searchdomain  = "vernify.com"
  ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeW4IbhjfdhAUmCZkIR7CazvI9kkEe8hauTMmf//2gzkWHqGfUfXxMbDCJAVtxtPzxCFNt7JEHvzYcvpCp/MFNBaNyAOk50+F5Gg9uaLww4AkgOgrLn8jI4FK6C+qjS7chf1pRrv3OZv2YUFiCYwOZcIqfR3FkGIfqAGxPlPLYxdym/xM2UOO6Ynw3BCGxxj/WR1L4zNymIj6h98ZjhlGX22sehgXsJNVSLKHdRD52iwB9GQDcrBRXfCAPM8Z8FZ2d56Bv4srRX+8ivi/2wnEUct0LQcYqAMBvLOAVlzKchfOjj8w3Aps0pDRrdTUqHUbou1QUBDKVhCHyZN9GcEM/ werner@werner-linux.ics.dmz"

  rootfs {
    storage = "ceph01"
    size    = "10G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${local.ip}/24"
    ip6    = "auto"
    gw     = local.gateway
  }
}

resource "null_resource" "wait_for_vm" {
  depends_on = [proxmox_lxc.network_docker]

  provisioner "local-exec" {
    command = <<EOT
    while ! ping -c 1 -W 1 ${replace(proxmox_lxc.network_docker.network.0.ip, "/24", "")}; do
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
      "sudo apt install -y ca-certificates curl wget git",
      "sudo systemctl daemon-reload",
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
    source      = "${path.module}/docker-compose.yml"
    destination = "/home/werner/docker-compose.yml"
  }

  # Start stack
  provisioner "remote-exec" {
    inline = [
      "cd /home/werner",
      "docker compose up -d"
    ]
  }
}
