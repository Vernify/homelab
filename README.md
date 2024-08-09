# Home lab
IaC to setup my home lab

# NOTE
This is a place where I put my notes as I learn how to do things better,
feel free to use this code in any (kind) manner, but please do be very careful before using it in any production implementation. Learning takes favour over security as I learn.

# Home lab layout
I recently called it on my love for VMWare. For the last 10 years, I have been a staunch supporter of vSphere, running a full HA stack in my home lab.
Largely because I work in enterprise, and that has always been the hypervisor of choice. I have just recently gave in, and will re-provision my entire home lab over onto Proxmox, and use the opportunity to get rid of a few manual steps.

5 HA Proxmox hypervisors, with shared storage provided through Ceph and a NFS mount.

# Directories in the repo
## proxmox
* Code to configure proxmox

## vm_templates
* Packer code to build new VM templates for consumption through automation.

## k3s
* Code to provision and deploy a K3S cluster. 
* Consists of 3 masters, and 3 workers by default.

# The Lab:

## Platform
* [Proxmox] - Hypervisor layer
  * [Installation](https://linuxadmin.co.nz/index.php/2024/08/07/install-proxmox/)
* Distributed storage
  * [Longhorn] (if not sticking with Ceph)
* Provisioning and management container(s)
  * Terraform
  * Ansible
  * Jenkins
* AWX deployment on K3S
* Hashi Vault deployment on K3S
* Pihole deployment on K3S
* Jenkins
* Chef

## Access
* PAM (Incl CA and access proxy)
  * [Teleport](https://goteleport.com)
* Zero-trust Network access
  * [Twingate](https://www.twingate.com)
* OpenVPN client node

## Notification and monitoring
* Shortcut Dashboard 
  * [Dashy](https://dashy.to)
  * [Icons](https://github.com/walkxcode/dashboard-icons/blob/main/ICONS.md)
* Push Notifications
  * [Gotify](https://gotify.net)
* Graphite
* Graylog
* Grafana

## Media apps
* Plex and related *arr containers

## Other apps
* Bootstrap and Wordpress sites

<!-- References -->
[Proxmox]: https://www.proxmox.com/en/
[Longhorn]: https://docs.k3s.io/storage