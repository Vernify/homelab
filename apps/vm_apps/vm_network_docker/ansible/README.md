Ansible layout for vm_network_docker

Structure:
- `ansible.cfg` - local ansible config
- `inventory/hosts.yml` - hosts inventory
- `playbooks/deploy.yml` - playbook to run role
- `roles/vm_network_docker/` - role with tasks, defaults, handlers, templates
- `vault-pass.txt.sample` - sample vault password placeholder (do not commit real password)
