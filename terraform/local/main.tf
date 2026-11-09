
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# A small Ubuntu image with SSH enabled.
# Docker and PostgreSQL will be installed manually during the assignment.
data "docker_image" "local_server" {
  name = "campus-notifier-local-server:latest"
}

# Network connecting the application and database servers.
resource "docker_network" "campus_network" {
  name   = "campus-notifier-network"
  driver = "bridge"
}

# Application server
resource "docker_container" "app_server" {
  name  = "campus-notifier-app-server"
  image = data.docker_image.local_server.id

  # Copy the SSH public key into the correct location,
  # set secure permissions, and start the SSH daemon.
  command = [
    "sh",
    "-c",
    "install -o root -g root -m 600 /tmp/authorized_keys /root/.ssh/authorized_keys && exec /usr/sbin/sshd -D"
  ]

  restart  = "unless-stopped"
  must_run = true
  start    = true

  ports {
    internal = 22
    external = var.app_ssh_port
    ip       = "127.0.0.1"
  }

  ports {
    internal = 8080
    external = var.app_server_host_port
    ip       = "0.0.0.0"
  }

  # Allow Docker CLI commands inside this server
  # to communicate with the Docker daemon.
  volumes {
    host_path      = var.docker_socket_path
    container_path = "/var/run/docker.sock"
  }

  # Mount the public key temporarily as read-only.
  # It will be copied to authorized_keys during startup.
  volumes {
    host_path      = pathexpand(var.ssh_public_key_path)
    container_path = "/tmp/authorized_keys"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.campus_network.name
  }
}

# Database server
resource "docker_container" "db_server" {
  name  = "campus-notifier-db-server"
  image = data.docker_image.local_server.id

  # Apply the same SSH key installation procedure.
  command = [
    "sh",
    "-c",
    "install -o root -g root -m 600 /tmp/authorized_keys /root/.ssh/authorized_keys && exec /usr/sbin/sshd -D"
  ]

  restart  = "unless-stopped"
  must_run = true
  start    = true

  ports {
    internal = 22
    external = var.db_ssh_port
    ip       = "127.0.0.1"
  }

  # Mount the public key temporarily as read-only.
  volumes {
    host_path      = pathexpand(var.ssh_public_key_path)
    container_path = "/tmp/authorized_keys"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.campus_network.name
  }
}

