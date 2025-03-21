terraform {
    required_version = ">= 0.13.0"
}

provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "default"
}

resource "kubernetes_namespace" "unify" {
  metadata {
    name = "unify"
  }
}

# Need to run mongo db and unify controller in the same namespace
resource "kubernetes_deployment" "mongo" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace.unify.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mongo"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }

      spec {
        container {
          name  = "mongo"
          image = "mongo:latest"

          port {
            container_port = 27017
            name           = "mongo"
          }

          volume_mount {
            name       = "mongo-data"
            mount_path = "/data/db"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "unify" {
  metadata {
    name      = "unify"
    namespace = kubernetes_namespace.unify.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "unify"
      }
    }

    template {
      metadata {
        labels = {
          app = "unify"
        }
      }

      spec {
        container {
          name  = "unify"
          image = "linuxserver/unifi-controller:latest"

          port {
            container_port = 8080
            name           = "http"
          }

          port {
            container_port = 8443
            name           = "https"
          }

          port {
            container_port = 3478
            name           = "stun"
          }

          port {
            container_port = 10001
            name           = "stun-dtls"
          }

          port {
            container_port = 1900
            name           = "upnp"
          }

          port {
            container_port = 6789
            name           = "speedtest"
          }

          env {
            name  = "TZ"
            value = "Pacific/Auckland"
          }

          env {
            name  = "PUID"
            value = "1000"
          }

          env {
            name  = "PGID"
            value = "1000"
          }

          volume_mount {
            name       = "unify-config"
            mount_path = "/config"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "unify" {
  metadata {
    name      = "unify"
    namespace = kubernetes_namespace.unify.metadata[0].name
  }

  spec {
    selector = {
      app = "unify"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    port {
      port        = 8443
      target_port = 8443
    }

    port {
      port        = 3478
      target_port = 3478
    }

    port {
      port        = 10001
      target_port = 10001
    }

    port {
      port        = 1900
      target_port = 1900
    }

    port {
      port        = 6789
      target_port = 6789
    }
  }
}
