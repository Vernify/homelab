variable "vmid" {
  default = 1114
}
resource "proxmox_lxc" "media" {
    vmid          = var.vmid
    target_node   = "pve03"
    hostname      = "media"
    ostemplate    = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
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
      size    = "50G"
    }

    network {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "192.168.22.114/24"
      ip6    = "auto"
      gw     = "192.168.22.1"
    }
}
output "container_ip" {
  value = "${proxmox_lxc.media.network.0.ip}"
}

resource "null_resource" "wait_for_media" {
    depends_on = [proxmox_lxc.media]

    provisioner "local-exec" {
        command = <<EOT
        while ! ping -c 1 -W 1 ${replace(proxmox_lxc.media.network.0.ip, "/24", "")}; do
            sleep 5
        done
        EOT
    }
}

# Install Apps
resource "null_resource" "install_media" {
    depends_on = [null_resource.wait_for_media]

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            host        = replace(proxmox_lxc.media.network.0.ip, "/24", "")
            user        = "root"
            private_key = file("~/.ssh/id_rsa")
        }

        inline = [
            "sudo add-apt-repository ppa:jcfp/nobetas",
            "sudo apt-get update",
            "sudo apt-get install -y nfs-common curl sqlite3 wget git-core python3-lxml sabnzbdplus ffmpeg mediainfo p7zip-full unrar unzip python3-pip",
            "sudo mkdir -p /media",
            "echo '192.168.50.210:/volume2/media /media nfs defaults,nolock 0 0' | sudo tee -a /etc/fstab",
            "sudo mount -a",
            <<-EOF
            curl -o- https://raw.githubusercontent.com/Sonarr/Sonarr/develop/distribution/debian/install.sh | sudo bash
            wget --content-disposition 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
            tar -xvzf Radarr*.linux*.tar.gz
            sudo mv Radarr /opt/
            sudo chown -R radarr:radarr /opt/Radarr
            cat << EOT | sudo tee /etc/systemd/system/radarr.service > /dev/null
            [Unit]
            Description=Radarr Daemon
            After=syslog.target network.target
            [Service]
            User=radarr
            Group=media
            Type=simple

            ExecStart=/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr/
            TimeoutStopSec=20
            KillMode=process
            Restart=on-failure
            [Install]
            WantedBy=multi-user.target
            EOT
            sudo systemctl enable radarr
            sudo systemctl start radarr
            sudo systemctl -q daemon-reload
            sudo systemctl enable --now -q radarr
            rm Radarr*.linux*.tar.gz
            EOF
        ]
    }
}