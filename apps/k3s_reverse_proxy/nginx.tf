# Create a reverse proxy for the k3s cluster
# The server should act as reverse proxy for:
# nzbget.vernify.com -> 192.168.22.26:6789
# prowlarr.vernify.com -> 192.168.22.26:9696
# sonarr.vernify.com -> 192.168.22.26:8989
# radarr.vernify.com -> 192.168.22.26:7878
# bazarr.vernify.com -> 192.168.22.26:6767
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create a ConfigMap for the Nginx configuration
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name = "nginx-config"
  }

  data = {
    "nginx.conf" = <<-EOT
      events {}
      http {
        server {
          listen 80;

          server_name nzbget.vernify.com;
          location / {
            proxy_pass http://192.168.22.26:6789;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        }

        server {
          listen 80;

          server_name prowlarr.vernify.com;
          location / {
            proxy_pass http://192.168.22.26:9696;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        }

        server {
          listen 80;

          server_name sonarr.vernify.com;
          location / {
            proxy_pass http://192.168.22.26:8989;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        }

        server {
          listen 80;

          server_name radarr.vernify.com;
          location / {
            proxy_pass http://192.168.22.26:7878;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        }

        server {
          listen 80;

          server_name bazarr.vernify.com;
          location / {
            proxy_pass http://192.168.22.26:6767;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        }
      }
    EOT
  }
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

