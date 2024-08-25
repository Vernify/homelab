# Create a credentials.pkr.hcl file in ./packer, with the following content:
proxmox_api_url = "https://<proxmox host>:8006/api2/json" 
proxmox_api_token_id = "terraform_user@pam!terraform_packer" 
proxmox_api_token_secret = "<proxmox api token>"
ssh_password = "<SHA256 of your password>"

# Executing
packer build -var-file=credentials.pkr.hcl ubuntu-server-jammy/template.pkr.hcl
OR
packer build -debug -var-file=credentials.pkr.hcl ubuntu-server-jammy/template.pkr.hcl
OR
PACKER_LOG=1 packer build -var-file=../credentials.pkr.hcl ubuntu-server-jammy/template.pkr.hcl
