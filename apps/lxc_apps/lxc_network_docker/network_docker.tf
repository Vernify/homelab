resource "proxmox_lxc" "vernify_lxc_container" {
  vmid          = var.vmid
  target_node   = var.target_node
  hostname      = var.hostname
  ostemplate    = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password      = base64encode(var.vmid)
  onboot        = true
  start         = true
  hastate       = "started"
  hagroup       = "Default"
  memory        = var.memory
  searchdomain  = var.searchdomain
  nameserver    = var.nameserver
  ssh_public_keys = file("~/.ssh/id_rsa.pub")
  unprivileged  = false

  rootfs {
    storage = "ceph01"
    size    = var.disk
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${var.ip}/24"
    ip6    = "manual"
    gw     = var.gateway
  }

  features {
    nesting = true
  }
}

resource "null_resource" "wait_for_vm" {
  depends_on = [proxmox_lxc.vernify_lxc_container]

  provisioner "local-exec" {
    command = <<EOT
    while ! ping -c 1 -W 1 ${replace(proxmox_lxc.vernify_lxc_container.network.0.ip, "/24", "")}; do
        sleep 5
    done
    EOT
  }
}

resource "null_resource" "install_media" {
  depends_on = [null_resource.wait_for_vm]

  connection {
    type        = "ssh"
    host        = var.ip
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
#      "apt update -y",
#      "apt install -y apt-transport-https ca-certificates curl gnupg lsb-release git",
#      "cd /opt",
#      "git clone -b release https://github.com/netbox-community/netbox-docker.git netbox",
#      "useradd -m -s /bin/bash werner",
#      "mkdir -p /home/werner/.ssh",
#      "echo '${file("~/.ssh/id_rsa.pub")}' >> /home/werner/.ssh/authorized_keys",
#      "chown -R werner:werner /home/werner/.ssh",
#      "chmod 700 /home/werner/.ssh",
#      "chmod 600 /home/werner/.ssh/authorized_keys",
#      "echo 'werner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/werner",
#      "chmod 440 /etc/sudoers.d/werner",
#      "systemctl stop apparmor",
#      "systemctl disable apparmor",
#      "apt remove --assume-yes --purge apparmor",
#      "echo 'Package: apparmor*' | sudo tee /etc/apt/preferences.d/disable-apparmor",
#      "echo 'Pin: release *' | sudo tee -a /etc/apt/preferences.d/disable-apparmor",
#      "echo 'Pin-Priority: -1' | sudo tee -a /etc/apt/preferences.d/disable-apparmor",
#      "rm -f /usr/share/keyrings/docker-archive-keyring.gpg",
#      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
#      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
#      "apt update -y",
#      "apt-get install -y docker-ce docker-ce-cli containerd.io",
#      "groupadd docker || true",
#      "usermod -aG docker werner",
#      "systemctl enable docker",
#      "systemctl start docker",
#      "cd /opt/netbox",
#      "docker compose pull",
#      "docker compose up -d",
    ]
  }
#
#"curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
#"chmod +x /usr/local/bin/docker-compose",
#"ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
# "while ! docker inspect -f '{{.State.Health.Status}}' netbox-netbox-1 | grep -q 'healthy'; do sleep 10; done"

#  provisioner "file" {
#    source      = "${path.module}/docker-compose.override.yml"
#    destination = "/opt/netbox/docker-compose.override.yml"
#  }

#  provisioner "file" {
#    content = <<-EOT
#    DO
#    $$
#    BEGIN
#       IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'netbox') THEN
#          EXECUTE 'CREATE DATABASE netbox';
#       END IF;
#    END
#    $$;
#    EOT
#    destination = "/home/werner/init.sql"
#  }
#
#  provisioner "remote-exec" {
#    inline = [
#      "echo '[Unit]' > /etc/systemd/system/docker-compose-app.service",
#      "echo 'Description=Docker Compose Application Service' >> /etc/systemd/system/docker-compose-app.service",
#      "echo 'After=network.target docker.service' >> /etc/systemd/system/docker-compose-app.service",
#      "echo '[Service]' >> /etc/systemd/system/docker-compose-app.service",
#      "echo 'Type=oneshot' >> /etc/systemd/system/docker-compose-app.service",
#      "echo 'RemainAfterExit=yes' >> /etc/systemd/system/docker-compose-app.service",
#      "echo 'WorkingDirectory=/home/werner' >> /etc/systemd/system/docker-compose-app.service",
#      "echo 'ExecStart=/usr/bin/docker compose up -d' >> /etc/systemd/system/docker-compose-app.service",
#      "echo 'ExecStop=/usr/bin/docker compose down' >> /etc/systemd/system/docker-compose-app.service",
#      "echo '[Install]' >> /etc/systemd/system/docker-compose-app.service",
#      "echo 'WantedBy=multi-user.target' >> /etc/systemd/system/docker-compose-app.service",
#      "systemctl enable docker-compose-app.service",
#      "shutdown -r +1 'System will reboot in 1 minute to complete setup.'"
#    ]
#  }
}