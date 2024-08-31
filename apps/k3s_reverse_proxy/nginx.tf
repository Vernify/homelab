# Get a list of all .conf files in the config directory
locals {
  config_files = fileset("${path.module}/config", "*.conf")
}

# Read the contents of all .conf files and join them into a single string
locals {
  config_content = join("\n", [for file in local.config_files : file("${path.module}/config/${file}")])
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
        ${local.config_content}
      }
    EOT
  }
}
