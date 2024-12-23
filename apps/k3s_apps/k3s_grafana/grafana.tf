# Deploy Grafana on K3s
terraform {
    required_version = ">= 0.13.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name = "grafana"
    labels = {
      app = "grafana"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          image = "grafana/grafana:latest"
          name  = "grafana"
          port {
            container_port = 3000
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 10
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name = "grafana"
  }

  spec {
    selector = {
      app = kubernetes_deployment.grafana.metadata[0].labels.app
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

output "grafana_url" {
  value = kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip
}

output "grafana_port" {
  value = kubernetes_service.grafana.spec[0].port[0].port
}
