## Deploy Hashicorp Vault on K3s (production-like setup)
#
#provider "kubernetes" {
#  config_path = "~/.kube/config"
#}
#
#provider "helm" {
#  kubernetes {
#    config_path = "~/.kube/config"
#  }
#}
#
#resource "kubernetes_namespace" "vault" {
#  metadata {
#    name = "vault"
#  }
#}
#
#resource "kubernetes_secret" "vault_unseal_key" {
#  metadata {
#    name      = "vault-unseal-key"
#    namespace = kubernetes_namespace.vault.metadata[0].name
#  }
#
#  data = {
#    unseal_key = base64encode("your-unseal-key-here")
#  }
#}
#
#resource "helm_release" "vault" {
#  name                      = "vault"
#  namespace                 = kubernetes_namespace.vault.metadata[0].name
#  repository                = "https://helm.releases.hashicorp.com"
#  chart                     = "vault"
#  version                   = "0.19.0"
#  disable_openapi_validation = true
#  
#  # Disable the PodDisruptionBudget as a workaround for the deprecated API
#  set {
#    name  = "podDisruptionBudget.enabled"
#    value = "false"
#  }
#  
#  # Production configuration:
#  set {
#    name  = "server.ha.enabled"
#    value = "true"
#  }
#
#  set {
#    name  = "server.ha.raft.enabled"
#    value = "true"
#  }
#
#  set {
#    name  = "server.dataStorage.enabled"
#    value = "true"
#  }
#
#  set {
#    name  = "server.dataStorage.size"
#    value = "10Gi"
#  }
#}
#