# Lab Layout
Compute are provided through 5 HA Proxmox hypervisors, with shared storage provided by Ceph and a NFS export.

# Credits
All the heavy lifting in this repo has been done by others. Most notably on the work and references by Techno Tim and Christian Lempa. 

# The Lab:
Code reviewed since Aug 2024.

# What does it do (currently)?
* Spin up the provisioning container [Instructions](https://github.com/Vernify/homelab/tree/main/provisioning_container)
* Stand up HA Proxmox cluster through Ansible:
  * Bind and configure the Proxmox nodes into a cluster.
  * Configure agents, register, and deploy Lets Encrypt certs to all nodes
  * Setup notification services through Gmail
  * Seed the cluster with selected LXC images
  * Seeds the cluster with ISOs of selected OS
  * Use Packer to build and seed the cluster with VM templates
* Stand up HA K3S cluster through Terraform and Ansible:
  * Provision 5 VMs spread across the nodes in the cluster
  * Install and configure 3 as K3S control planes
  * Install and configure 2 as K3S nodes
  * Deploy, configure, and deploy MetalLB

# Technologies
## Provisioning Platform
The following makes up my home lab. I'll add the code as I review and refactor them for 2024. 
Will add ticks as they are migrated over.
* &check; [Proxmox] - Hypervisor layer
* &cross; [Proxmox backup server](https://www.proxmox.com/en/proxmox-backup-server/overview) - Backups
* &check; [Packer] templates
* &check; [VMs](https://github.com/Vernify/homelab/tree/main/vm_templates/packer/)
* &cross; Ceph Distributed storage provided and configured as part of Proxmox
  * &cross; [Longhorn] (if not sticking with Ceph)
* &check; [K3S] container platform
  * [Traefik] [Techno Tim walkthrough](https://technotim.live/posts/kube-traefik-cert-manager-le/)

## Services Platform
* [AWX] deployment on K3S
* Hashicorp [Vault] deployment on K3S
  * Looking at [Conjur] and [Summon] as possible replacement
* [Pi-hole] deployment on K3S
* [Jenkins] for CI
* [Cinc] (Open-source Chef)
* [Postfix] for MTA
* [Netbox] for IPAM
* [Cloudflare] for DNS
* [Rancher] for orchestration
  * [Techno Tim Walkthrough](https://technotim.live/posts/rancher-ha-install/#install)

## Access
* [Teleport] - PAM (Incl CA and access proxy)
* [Twingate] - Zero-trust Network access
* [OpenVPN] - Client gateway to connect to customers
* [Fail2Ban] to protect against brute-force attacks

## Notification and monitoring
* [Dashy] as lab front door, with sourced [icons]
* [Gotify] push notifications
* [Graphite] for metric storage
  * [Prometheus] possible replacement for metrics and alerting
* [Graylog] for log aggregation
* [Grafana] for observability
* [Betterstack] for alerting and external monitoring
  * [Openstatus] possible open-source replacement external monitoring

## Media apps
* [Plex] and related containers

## Other apps
* [AdminLTE] - Bootstrap sites
* Wordpress blogs

<!-- References Start -->
[Proxmox]: https://www.proxmox.com/en/
[Longhorn]: https://docs.k3s.io/storage
[Teleport]: https://goteleport.com
[Twingate]: https://www.twingate.com
[Dashy]: https://dashy.to
[Icons]: https://github.com/walkxcode/dashboard-icons/blob/main/ICONS.md
[Gotify]: https://gotify.net
[Graphite]: https://github.com/graphite-project/graphite-web/blob/master/README.md
[Graylog]: https://graylog.org
[Grafana]: https://grafana.com
[AdminLTE]: https://adminlte.io
[Terraform]: https://www.terraform.io
[Ansible]: https://www.ansible.com
[Jenkins]: https://www.jenkins.io
[Cinc]: https://cinc.sh
[Postfix]: https://www.postfix.org
[AWX]: https://www.ansible.com/awx/
[Vault]: https://www.hashicorp.com/products/vault
[Packer]: https://www.hashicorp.com/products/packer
[Pi-hole]: https://pi-hole.net
[Plex]: https://www.plex.tv/sign-in/?forwardUrl=https%3A%2F%2Fwww.plex.tv%2F
[OpenVPN]: https://openvpn.net
[Prometheus]: https://prometheus.io
[Betterstack]: https://betterstack.com
[Openstatus]: https://www.openstatus.dev
[Netbox]: https://netboxlabs.com/docs/netbox/en/stable/
[Rancher]: https://www.rancher.com
[Traefik]: https://traefik.io/traefik/
[Lets Encrypt]: https://letsencrypt.org
[Cloudflare]: https://www.cloudflare.com
[Fail2Ban]: https://github.com/fail2ban/fail2ban
[Conjur]: https://docs.cyberark.com/conjur-cloud/latest/en/Content/Resources/_TopNav/cc_Home.htm
[Summon]:https://www.conjur.org/api/#inject-secrets
<!-- References End -->