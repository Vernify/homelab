# Quickstart
A few manual steps are required to enable the automation after a manual install of Proxmox.

## Build the container
`docker build -t provisioning_container .`

## Start up the container
Execute the container through:
`docker run -it --rm provisioning_container`

During development
`docker run -it --rm -v $(pwd)/../:/homelab provisioning_container`

## Configure access
`ssh-copy-id root@proxmox node(s)`

## Test connectivity
From within the proxmox/ansible directory
`ansible all -m ping -i inventory/hosts_demo.yml`
`ansible-playbook playbooks/test_connectivity.yml`

## Configure secrets
### Packer
Create a credentials.pkr.hcl file in the /homelab/vm_templates/packer directory, with the following content:
```
proxmox_api_url = "https://<proxmox host>:8006/api2/json" 
proxmox_api_token_id = "terraform_user@pam!terraform_packer" 
proxmox_api_token_secret = "<proxmox api token>"
ssh_password = "<SHA256 of your password>"
```

### Ansible
Create a secrets.yml, and a .vault_pass.txt file in the /homelab/proxmox/ansible/vault directory.
Place your vault password inside .vault_pass.txt
Create an Ansible vault in secrets.yml with the following content:
```
cluster_password: <cleartext ssh passwords of hosts>
to_address: <receipient email address of cluster notifications>
gmail_username: <username of Gmail sender>
gmail_app_password: <Gmail app password>
cloudflare_email: <Cloudflare email address>
cloudflare_api_key: '<Cloudflare API key>'
```

## Kick off the provisioning
`ansible-playbook playbooks/configure_proxmox.yml`

# References
[Proxmox API](https://pve.proxmox.com/pve-docs/api-viewer/index.html)
