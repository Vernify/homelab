# This will deploy Graphite on the K3s cluster
# docker run -d --name graphite --restart=always -p 80:80 -p 2003-2004:2003-2004 -p 2023-2024:2023-2024  -p 8125:8125/udp  -p 8126:8126  graphiteapp/graphite-statsd
terraform {
    required_version = ">= 0.13.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "graphite" {
  metadata {
    name = "graphite"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "graphite"
      }
    }

    template {
      metadata {
        labels = {
          app = "graphite"
        }
      }

      spec {
        container {
          name  = "graphite"
          image = "graphiteapp/graphite-statsd"
          port {
            container_port = 80
          }
          port {
            container_port = 2003
          }
          port {
            container_port = 2004
          }
          port {
            container_port = 2023
          }
          port {
            container_port = 2024
          }
          port {
            container_port = 8125
          }
          port {
            container_port = 8126
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "graphite" {
  metadata {
    name = "graphite"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "graphite"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "carbon-tcp-2003"
      port        = 2003
      target_port = 2003
    }

    port {
      name        = "carbon-tcp-2004"
      port        = 2004
      target_port = 2004
    }

    port {
      name        = "carbon-tcp-2023"
      port        = 2023
      target_port = 2023
    }

    port {
      name        = "carbon-tcp-2024"
      port        = 2024
      target_port = 2024
    }

    port {
      name        = "statsd-udp"
      port        = 8125
      target_port = 8125
      protocol    = "UDP"
    }

    port {
      name        = "statsd-tcp"
      port        = 8126
      target_port = 8126
    }
  }
}