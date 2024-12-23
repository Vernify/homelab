# Deploy kube-prometheus-stack using Helm
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
  default = "monitoring"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    annotations = {
      "meta.helm.sh/release-name"      = "monitoring"
      "meta.helm.sh/release-namespace" = var.namespace
    }
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = var.namespace
  chart      = "./kube-prometheus-stack/"
  values     = [
    file("./kube-prometheus-stack/values.yaml")
  ]
}

output "kube_prometheus_stack" {
  value = helm_release.kube_prometheus_stack.metadata
}

