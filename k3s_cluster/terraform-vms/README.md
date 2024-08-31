Create a ./credentials.auto.tfvars file, with the following info:

proxmox_api_url = "https://<proxmox host>:8006/api2/json"
proxmox_api_token_id = "terraform_user@pam!terraform_packer"
proxmox_api_token_secret = "<proxmox API secret>"

