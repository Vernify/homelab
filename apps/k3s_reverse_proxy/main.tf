# Create a reverse proxy for the k3s cluster
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Deploy the Nginx container
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:1.19.6"
          name  = "nginx"

          volume_mount {
            name       = "nginx-config-volume"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
          }

          port {
            container_port = 80
          }
        }

        volume {
          name = "nginx-config-volume"

          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Expose the Nginx container
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

output "nginx_service_ip" {
  value = kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.ip
}