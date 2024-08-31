# Create a reverse proxy for the k3s cluster
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

        # Prowlarr
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

        # Sonarr
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

        # Radarr
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

        # Bazarr
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

        # Home Assistant
        server {
          listen 80;

          server_name homeassistant.vernify.com;
          location / {
            proxy_pass http://192.168.22.27:8123;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        }

        # Graphite listens on ports 80,2003,2004,2023,2024,8125,8126
        server {
          listen 80;
          server_name graphite.vernify.com;
        
          location / {
            proxy_pass http://192.168.22.73:80;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        
          location /2003 {
            proxy_pass http://192.168.22.73:2003;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        
          location /2004 {
            proxy_pass http://192.168.22.73:2004;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        
          location /2023 {
            proxy_pass http://192.168.22.73:2023;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        
          location /2024 {
            proxy_pass http://192.168.22.73:2024;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        
          location /8125 {
            proxy_pass http://192.168.22.73:8125;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        
          location /8126 {
            proxy_pass http://192.168.22.73:8126;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        }

        # Grafana
        server {
          listen 80;

          server_name grafana.vernify.com;
          location / {
            proxy_pass http://192.168.22.74:3000;
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