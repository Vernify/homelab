variable "vmid" {
  default = 022113
}
resource "proxmox_lxc" "plex" {
    vmid          = var.vmid
    target_node   = "pve08"
    hostname      = "plex"
    ostemplate    = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    password      = base64encode(var.vmid)
    unprivileged  = true
    onboot        = true
    start         = true
    hastate       = "started"
    hagroup       = "Default"
    memory        = "8192"
    searchdomain  = "vernify.com"
    ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeW4IbhjfdhAUmCZkIR7CazvI9kkEe8hauTMmf//2gzkWHqGfUfXxMbDCJAVtxtPzxCFNt7JEHvzYcvpCp/MFNBaNyAOk50+F5Gg9uaLww4AkgOgrLn8jI4FK6C+qjS7chf1pRrv3OZv2YUFiCYwOZcIqfR3FkGIfqAGxPlPLYxdym/xM2UOO6Ynw3BCGxxj/WR1L4zNymIj6h98ZjhlGX22sehgXsJNVSLKHdRD52iwB9GQDcrBRXfCAPM8Z8FZ2d56Bv4srRX+8ivi/2wnEUct0LQcYqAMBvLOAVlzKchfOjj8w3Aps0pDRrdTUqHUbou1QUBDKVhCHyZN9GcEM/ werner@werner-linux.ics.dmz"

    rootfs {
      storage = "ceph01"
      size    = "40G"
    }

    network {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "192.168.22.113/24"
      ip6    = "auto"
      gw     = "192.168.22.1"
    }

}
output "container_ip" {
  value = "${proxmox_lxc.plex.network.0.ip}"
}

resource "null_resource" "wait_for_plex" {
    depends_on = [proxmox_lxc.plex]

    provisioner "local-exec" {
        command = <<EOT
        while ! ping -c 1 -W 1 ${replace(proxmox_lxc.plex.network.0.ip, "/24", "")}; do
            sleep 5
        done
        EOT
    }
}

# Install Plex
resource "null_resource" "install_plex" {
    depends_on = [null_resource.wait_for_plex]

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            host        = replace(proxmox_lxc.plex.network.0.ip, "/24", "")
            user        = "root"
            private_key = file("~/.ssh/id_rsa")
        }

        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y nfs-common curl wget ffmpeg mediainfo p7zip-full unrar unzip",
            "sudo mkdir -p /media",
            "echo '192.168.50.210:/volume2/media /media nfs defaults,nolock 0 0' | sudo tee -a /etc/fstab",
            "sudo mount -a",
            "curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add - ",
            "echo 'deb https://downloads.plex.tv/repo/deb/ public main' | sudo tee /etc/apt/sources.list.d/plex.list",
            "sudo apt-get update",
            "sudo apt install plexmediaserver",
            "sudo systemctl start plexmediaserver",
            "sudo systemctl enable plexmediaserver",
        ]
    }
}