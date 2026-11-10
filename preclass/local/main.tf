terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "app" {
  name = var.image
}

resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app.image_id
  # checkov:skip=CKV_DOCKER_2: no healthcheck needed for local dev container
  # checkov:skip=CKV_DOCKER_3: restart policy not required for local dev container
  ports {
    internal = var.container_port
    external = var.external_port
  }
}
