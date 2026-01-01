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

## Configure the devices if required:
```bash
ssh admin@192.168.1.106 'mca-cli-op set-inform http://192.168.22.5:8080/inform'
```

To verify the device is connected:
```bash
ssh admin@192.168.1.106 'mca-cli-op info'
# Should show: Status: Connected (http://192.168.22.5:8080/inform)
```

If you need to debug, ssh into the server and run the command from there:

```bash
ssh admin@192.168.1.106
set-inform http://192.168.22.5:8080/inform
```

## Notes

- State files (*.tfstate) are local; consider using remote backend for team deployments
- Credentials should be in `credentials.auto.tfvars` (in .gitignore)
- The disk size can be adjusted in `variables.tf` (`disk_size_gb`)
