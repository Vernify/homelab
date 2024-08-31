terraform {
    required_version = ">= 0.13.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
