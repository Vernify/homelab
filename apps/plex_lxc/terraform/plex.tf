resource "proxmox_lxc" "plex" {
    target_node   = "pve01"
    hostname      = "plex"
    ostemplate    = "local:vztmpl/alpine-3.19-default_20240207_amd64.tar.xz"
    password      = "BasicLXCContainer"
    unprivileged  = true
    onboot        = true
    start         = true
    vmid          = 501

    rootfs {
      storage = "local-lvm"
      size    = "8G"
    }

    network {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "dhcp"
      ip6    = "auto"
    }

  # Create a 50G drive mounted at /backup
  # Mount is on the host, not the container
  #mountpoint {
  #  key     = "0"
  #  slot    = "0"
  #  storage = "syn05"
  #  mp      = "/backup"
  #  size    = "50G"
  #}
}

output "container_ip" {
  value = "${proxmox_lxc.saicom-vpn.network.0.ip}"
}

#resource "null_resource" "wait_for_ip" {
#    depends_on = [proxmox_lxc.saicom-vpn]
#
#    provisioner "local-exec" {
#        command = <<EOT
#        while [ -z "$(sshpass -p 'BasicLXCContainer' ssh -o StrictHostKeyChecking=no root@$(terraform output -raw proxmox_lxc.saicom-vpn.vmid) 'hostname -I')" ]; do
#            sleep 5
#        done
#        EOT
#    }
#}

#resource "null_resource" "provision_openvpn" {
#    depends_on = [null_resource.wait_for_ip]
#
#    provisioner "remote-exec" {
#        connection {
#            type     = "ssh"
#            user     = "root"
#            password = "BasicLXCContainer"
#            host     = "${terraform.output.lxc_ip}"
#        }
#
#        inline = [
#            "apk add openvpn",
#            "ip a s"
#        ]
#    }
#}
