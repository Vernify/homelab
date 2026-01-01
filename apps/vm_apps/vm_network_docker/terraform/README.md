# Terraform Configuration

Provisions the network-docker VM on Proxmox with disk storage for Docker data.

## Files

- **vm.tf** - Proxmox VM and disk resource definitions
- **variables.tf** - Variable definitions (IP ranges, storage sizes, etc)
- **provider.tf** - Proxmox provider configuration
- **terraform.tfvars** - Default variable values (customize per deployment)
- **credentials.auto.tfvars** - Proxmox credentials (not in repo, created locally)

## Usage

```bash
# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply configuration
terraform apply
```

After Terraform succeeds, run the Ansible playbook to configure the VM:
```bash
cd ../ansible
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml
```

## Notes

- State files (*.tfstate) are local; consider using remote backend for team deployments
- Credentials should be in `credentials.auto.tfvars` (in .gitignore)
- The disk size can be adjusted in `variables.tf` (`disk_size_gb`)
