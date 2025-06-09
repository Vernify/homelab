# This is a script to install Vault on a K3s cluster using Helm.
# It requires kubectl, and helm to be installed and configured.

# See:  https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-raft

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp/vault
helm install vault hashicorp/vault --values helm-vault-raft-values.yml

# Your release is named vault. To learn more about the release, try:
#  $ helm status vault
#  $ helm get manifest vault


kubectl exec vault-0 -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > cluster-keys.json

# Print the unseal key
export VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)
echo $VAULT_UNSEAL_KEY

kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY

#Join the vault-1&2 pod to the Raft cluster.
kubectl exec -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -ti vault-2 -- vault operator raft join http://vault-0.vault-internal:8200

# Use the unseal key from above to unseal vault-1
kubectl exec -ti vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec -ti vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY

# Display the root token 
jq -r ".root_token" cluster-keys.json

# Start an interactive shell session 
kubectl exec --stdin=true --tty=true vault-0 -- /bin/sh
 ->  vault login

# Enable an instance of the kv-v2 secrets engine
 -> vault secrets enable -path=secret kv-v2

# Create a secret
  -> vault kv put secret/webapp/config username="static-user" password="static-password"

# Read the secret
  -> vault kv get secret/webapp/config

# Exit the shell
  -> exit

# Update the values file to use the LoadBalancer service type
# Then execute:  helm upgrade vault hashicorp/vault --values helm-vault-raft-values.yml --install
# and maybe kubectl patch svc vault-active -p '{"spec": {"type": "LoadBalancer"}}'

# Print GUI URL
echo "Vault UI: http://$(kubectl get svc vault -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200"
