# Ansible Configuration

Configures the network-docker VM with Docker storage migration, UniFi Network Application, and Netbox.

## Directory Structure

```
ansible/
├── ansible.cfg           # Ansible configuration
├── inventory/
│   └── hosts.yml        # Host inventory with connection details
├── playbooks/
│   └── deploy.yml       # Main deployment playbook
└── roles/
    └── vm_network_docker/
        ├── defaults/    # Variable defaults
        ├── handlers/    # Service restart handlers
        ├── tasks/       # Task definitions
        └── templates/   # Config file templates
```

## Deployment

```bash
# Deploy the entire stack
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml

# Run with verbose output
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml -vv

# Run specific tag
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml -t unifi
```

## Configuration

All service configurations are templated and managed by Ansible:

- **UniFi**: Deployed from `roles/.../templates/docker-compose.unifi.yml.j2`
- **Netbox**: Configuration from templates
  - `netbox-configuration.py.j2` - Main Netbox config
  - `netbox.env.j2` - Environment variables with secrets
- **Docker Storage**: Automatic migration to dedicated disk (`/dev/vdb`)

## Backing Up Data

Only Docker volumes need backing up (everything else is in version control):

```bash
# On the VM
sudo tar czf /backup/network-docker-volumes-$(date +%Y%m%d).tar.gz \
  -C /var/lib/docker volumes/
```

## Restoring After Reprovisioning

```bash
# 1. Restore volumes
sudo tar xzf /backup/network-docker-volumes-YYYYMMDD.tar.gz -C /var/lib/docker

# 2. Run Ansible to redeploy configs
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml
```

## Vault (Optional)

To encrypt sensitive variables:

1. Create `vault-pass.txt` (add to .gitignore)
2. Encrypt variables: `ansible-vault encrypt roles/vm_network_docker/defaults/main.yml`
3. Run playbook: Ansible will prompt for vault password or use `vault-pass.txt`
