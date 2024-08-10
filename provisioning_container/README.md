# Provisioning 
Build the container
`docker build -t provisioning_container .`

Execute the container through:
`docker run -it --rm provisioning_container`


This entire repo will be mounted under `/homelab` inside the container

Quick test of connectivity
`ansible all -m ping -i /homelab/proxmox/ansible/inventory/hosts_demo.yml`
`ansible-playbook playbooks/test_connectivity.yml`

During development
`docker run -it --rm -v $(pwd)/../proxmox/ansible:/homelab provisioning_container`

# Quickstart
A few manual steps are required to enable the automation after a manual install of Proxmox.

Start up the container, and run

```
ssh-copy-id root@proxmox node(s)
```
