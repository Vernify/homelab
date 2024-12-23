locals {
  ip = "192.168.5.21"
  gateway = "192.168.5.1"
  nameserver = "192.168.5.1"
  searchdomain = "vernify.com"
}

resource "proxmox_vm_qemu" "iotel-vpn-vm" {
    name = "iotel-vpn"
    target_node = "pve08"
    vmid = 2002
    desc = "IOTel VPN server"
    onboot = true
    clone = "ubuntu-2404-template"
    full_clone = true
    agent = 1
    numa = true
    hotplug = "network,disk,usb,cpu,memory"
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 4096
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
            size = "10G"
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
    depends_on = [proxmox_vm_qemu.iotel-vpn-vm]

    provisioner "local-exec" {
        command = <<EOT
        while ! ping -c 1 -W 1 ${local.ip}; do
            sleep 5
        done
        EOT
    }
}

#resource "null_resource" "install_fortigate" {
#  depends_on = [null_resource.wait_for_vm]
#
#  provisioner "remote-exec" {
#    connection {
#      type        = "ssh"
#      host        = replace(proxmox_vm_qemu.iotel_vpn.network_interface[0].ip_address, "/24", "")
#      user        = "werner"
#      private_key = file("~/.ssh/id_rsa")
#    }
#    inline = [
#      "sudo useradd -m -s /bin/bash iotel",
#      "sudo apt update",
#      "sudo apt install -y gnupg",
#      "wget -O - https://repo.fortinet.com/repo/forticlient/7.2/ubuntu/DEB-GPG-KEY | sudo apt-key add -",
#      "echo 'deb [arch=amd64] https://repo.fortinet.com/repo/forticlient/7.2/ubuntu/ /stable multiverse' | sudo tee /etc/apt/sources.list.d/forticlient.list",
#      "sudo apt update",
#      "sudo apt install -y forticlient",
#      "sudo chmod -R 755 /opt/forticlient",
#      "sudo chown -R iotel:iotel /opt/forticlient"
#    ]
#  }
#}
#
#resource "null_resource" "configure_forticlient" {
#  depends_on = [null_resource.install_fortigate]
#
#  provisioner "remote-exec" {
#    connection {
#      type        = "ssh"
#      host        = replace(proxmox_vm_qemu.iotel_vpn.network_interface[0].ip_address, "/24", "")
#      user        = "root"
#      private_key = file("~/.ssh/id_rsa")
#    }
#    inline = [
#      "echo 'config vpn ssl settings' > /etc/forticlient.conf",
#      "echo '    set server \"169.255.232.228\"' >> /etc/forticlient.conf",
#      "echo '    set port 10443' >> /etc/forticlient.conf",
#      "echo '    set username \"Werner\"' >> /etc/forticlient.conf",
#      "echo '    set password \"${var.iotel_password}\"' >> /etc/forticlient.conf",
#      "echo '    set save_password enable' >> /etc/forticlient.conf",
#      "echo '    set auto_connect enable' >> /etc/forticlient.conf",
#      "echo 'end' >> /etc/forticlient.conf"
#    ]
#  }
#}