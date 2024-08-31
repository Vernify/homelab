terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

variable "namespace" {
  default = "graphite"
}

resource "kubernetes_namespace" "graphite" {
  metadata {
    name = var.namespace
    annotations = {
      "meta.helm.sh/release-name"      = "graphite"
      "meta.helm.sh/release-namespace" = var.namespace
    }
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }
}

resource "helm_release" "graphite" {
  name       = "graphite"
  namespace  = var.namespace
  chart      = "./graphite_chart/"
  values     = [
    file("./graphite_chart/values.yaml")
  ]
}

output "graphite" {
  value = helm_release.graphite.metadata
}