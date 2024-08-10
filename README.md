# Home lab
This is a place where I put my notes as I learn how to do things better,
feel free to use this code in any (kind) manner, but please do be very careful before using it in any production implementation. Learning takes favour over security as I learn.

I recently called it on my love for VMWare. For the past 10-15 years, I have been a staunch supporter of vSphere, running a full HA stack in my home lab for the past 10 years.
This also largely because I work in enterprise environments, and that has always been the hypervisor of choice. I have just recently decided to pivot, and will re-provision my entire home lab over onto Proxmox, and use the opportunity to get rid of a few manual steps that have plagued me in my setup.

# Lab Layout
Compute are provided through 5 HA Proxmox hypervisors, with shared storage provided by Ceph and a NFS export.

# Credits
All the heavy lifting in this repo has been done by others. Most notably on the work and references by Techno Tim and Christian Lempa. 

# The Lab:
Code reviewed since Aug 2024.

## Provisioning container
I wanted to start off with provisioning through a known container, to aid not polluting my system, but also to be able to re-provision at any time, from any device, without having to worry about dependencies.

* Provisioning and management container(s)
  * [Terraform]
  * [Ansible]

## Platform
* [Proxmox] - Hypervisor layer
  * Manual [installation](https://linuxadmin.co.nz/index.php/2024/08/07/install-proxmox/) since it is on bare metal
  * [Configuration](https://github.com/Vernify/homelab/tree/main/proxmox/ansible)
  * Proxmox backup server for backups
* [Packer] templates
  * [VMs](https://github.com/Vernify/homelab/tree/main/vm_templates/packer/)
* Distributed storage


## Code to be reviewed and added:

## Platform
  * [Longhorn] (if not sticking with Ceph)
* [K3S] container platform
  * [Traefik]
  * [Lets Encrypt]
  * [Techno Tim walkthrough](https://technotim.live/posts/kube-traefik-cert-manager-le/)
* [AWX] deployment on K3S
* Hashicorp [Vault] deployment on K3S
* [Pi-hole] deployment on K3S
* [Jenkins] for CI
* [Cinc] (Open-source Chef)
* [Postfix] for MTA
* [Netbox] for IPAM
* DNS is served by [Cloudflare]
* [Rancher] for orchestration
  * [Techno Tim Walkthrough](https://technotim.live/posts/rancher-ha-install/#install)

## Access
* [Teleport] - PAM (Incl CA and access proxy)
* [Twingate] - Zero-trust Network access
* [OpenVPN] - Client gateway to connect to customers
* Fail2Ban to protect against brute-force attacks

## Notification and monitoring
* [Dashy] as lab front door, with sourced [icons]
* [Gotify] push notifications
* [Graphite] for metric storage
* [Graylog] for log aggregation
* [Grafana] for observability
* [Prometheus] for metrics and alerting
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
<!-- References End -->