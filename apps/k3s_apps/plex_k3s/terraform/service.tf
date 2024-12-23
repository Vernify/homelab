# Plex Service
resource "kubernetes_service" "plex_service" {
  metadata {
    name = "plex-service"
  }

  spec {
    selector = {
      app = "plex"
    }

    port {
      port        = 32400
      target_port = 32400
    }

    type = "LoadBalancer"
  }
}

