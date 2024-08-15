resource "kubernetes_deployment" "plex" {
  metadata {
    name = "plex"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "plex"
      }
    }

    template {
      metadata {
        labels = {
          app = "plex"
        }
      }

      spec {
        container {
          image = "plexinc/pms-docker:latest"
          name  = "plex"

          port {
            container_port = 32400
          }

          volume_mount {
            mount_path = "/media"
            name       = "media-storage"
          }

          volume_mount {
            mount_path = "/config"
            name       = "plex-config-storage"
          }
        }

        volume {
          name = "media-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.media_pvc.metadata[0].name
          }
        }

        volume {
          name = "plex-config-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.plex_config_pvc.metadata[0].name
          }
        }
      }
    }
  }
}