# Provision nodes
resource "proxmox_vm_qemu" "k3s_nodes" {
    count = var.number_k3s_nodes

    # VM General Settings
    name = "k3s-node-0${count.index + 1}"
    # Until ceph is setup, we only have slow NFS storage
    # Therefore, provision all on the same node for now
    #target_node = "pve01" 
    #target_node = "pve0${count.index + 1}"
    target_node = "pve0${(count.index % var.number_hypervisor_nodes) + 1}"
    vmid = 401 + count.index
    desc = "K3S Node 0${count.index + 1}"

    # VM Advanced General Settings
    onboot = true 

    # VM OS Settings
    clone = "ubuntu-2404-template"
    full_clone = true

    # VM System Settings
    agent = 1
    numa = true
    hotplug = "network,disk,usb,cpu,memory"

    # VM CPU Settings
    cores = 1
    sockets = 1
    cpu = "host"

   # VM Memory Settings
    memory = 2048

    # VM Disk Settings
    bootdisk = "virtio0"
    scsihw = "virtio-scsi-pci"

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
                    storage = "local-lvm"
                    format = "raw"
                }
            }
        }
    }

    # VM Network Settings
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }
    ipconfig0 = "ip=192.168.75.4${count.index + 1}/24,gw=192.168.75.1"
    nameserver = "192.168.75.1"
    searchdomain = "vernify.com"
    skip_ipv6 = true

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # Wait for the cloud-init process to complete and reboot to complete provisioning
    provisioner "remote-exec" {
        inline = [
            "while [ $(cloud-init status | grep -c 'status: done') -eq 0 ]; do sleep 5; done",
            "sudo reboot"
        ]

        connection {
            type        = "ssh"
            user        = "werner"
            private_key = file("~/.ssh/id_rsa")
            host        = split("/", split(",", split("=", self.ipconfig0)[1])[0])[0]
            agent       = false
        }
    }
}
