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

# Sonarr Service
#resource "kubernetes_service" "sonarr_service" {
#  metadata {
#    name = "sonarr-service"
#  }
#
#  spec {
#    selector = {
#      app = "sonarr"
#    }
#
#    port {
#      port        = 8989
#      target_port = 8989
#    }
#
#    type = "LoadBalancer"
#  }
#}
#
## Couchpotato Service
#resource "kubernetes_service" "couchpotato_service" {
#  metadata {
#    name = "couchpotato-service"
#  }
#
#  spec {
#    selector = {
#      app = "couchpotato"
#    }
#
#    port {
#      port        = 5050
#      target_port = 5050
#    }
#
#    type = "LoadBalancer"
#  }
#}
#
## Radarr Service
#resource "kubernetes_service" "radarr_service" {
#  metadata {
#    name = "radarr-service"
#  }
#
#  spec {
#    selector = {
#      app = "radarr"
#    }
#
#    port {
#      port        = 7878
#      target_port = 7878
#    }
#
#    type = "LoadBalancer"
#  }
#}
#
## SABNZB Service
#resource "kubernetes_service" "sabnzbd_service" {
#  metadata {
#    name = "sabnzbd-service"
#  }
#
#  spec {
#    selector = {
#      app = "sabnzbd"
#    }
#
#    port {
#      port        = 8080
#      target_port = 8080
#    }
#
#    type = "LoadBalancer"
#  }
#}
