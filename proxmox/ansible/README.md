# IaC to configure Proxmox after a vanilla install

# Requirements:
* Modify inventory/group_vars/all.yml as required
* Create an ansible-vault in /vault/secrets.yml with the following secrets
  * cluster_password: root password of the nodes
  * to_address: email address that should receive notifications
  * gmail_username: Gmail username that will send the mails
  * gmail_app_password: App password to send email
* Create a vault/.vault_pass.txt file with your vault password
