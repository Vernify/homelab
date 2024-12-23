provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "pihole" {
  metadata {
    name = "pihole"
  }
}

resource "kubernetes_deployment" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "pihole"
      }
    }

    template {
      metadata {
        labels = {
          app = "pihole"
        }
      }

      spec {
        container {
          name  = "pihole"
          image = "pihole/pihole:latest"

          port {
            container_port = 80
            name           = "http"
          }

          port {
            container_port = 53
            name           = "dns"
            protocol       = "UDP"
          }

          env {
            name  = "TZ"
            value = "Pacific/Auckland"
          }

          env {
            name  = "WEBPASSWORD"
            value = var.password
          }

          volume_mount {
            name       = "pihole-config"
            mount_path = "/etc/pihole"
          }

          volume_mount {
            name       = "dnsmasq-config"
            mount_path = "/etc/dnsmasq.d"
          }
        }

        volume {
          name = "pihole-config"

          persistent_volume_claim {
            claim_name = "pihole-pvc"
          }
        }

        volume {
          name = "dnsmasq-config"

          persistent_volume_claim {
            claim_name = "dnsmasq-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    selector = {
      app = "pihole"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

    port {
      port        = 53
      target_port = 53
      protocol    = "UDP"
      name        = "dns"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "pihole" {
  metadata {
    name      = "pihole-pvc"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "dnsmasq" {
  metadata {
    name      = "dnsmasq-pvc"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}