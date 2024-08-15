resource "kubernetes_persistent_volume" "media_pv" {
  metadata {
    name = "plex-media-pv"
  }

  spec {
    capacity = {
      storage = "500Ti"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_reclaim_policy = "Retain"

    storage_class_name = "immediate-local-path"

    persistent_volume_source {
      nfs {
        path   = "/volume2/Media"
        server = "192.168.50.210"
      }
    }

    mount_options = ["nolock"]
  }
}

resource "kubernetes_persistent_volume" "plex_config_pv" {
  metadata {
    name = "plex-config-pv"
  }

  spec {
    capacity = {
      storage = "50Gi"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_reclaim_policy = "Retain"

    storage_class_name = "immediate-local-path"

    persistent_volume_source {
      nfs {
        path   = "/volume2/docker/plex"
        server = "192.168.50.210"
      }
    }

    mount_options = ["nolock"]
  }
}

resource "kubernetes_persistent_volume_claim" "media_pvc" {
  metadata {
    name = "plex-media-pvc"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "500Ti"
      }
    }
    storage_class_name = "immediate-local-path"
  }
}

resource "kubernetes_persistent_volume_claim" "plex_config_pvc" {
  metadata {
    name = "plex-config-pvc"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
    storage_class_name = "immediate-local-path"
  }
}