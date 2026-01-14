terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "devops_net" {
  name = "devops-net"
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = "postgres:15"

  restart = "unless-stopped"

  env = [
    "POSTGRES_DB=app_db",
    "POSTGRES_USER=app_user",
    "POSTGRES_PASSWORD=app_password"
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.devops_net.name
  }

  ports {
    internal = 5432
    external = 5432
  }
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = "nginx:latest"

  networks_advanced {
    name = docker_network.devops_net.name
  }

  ports {
    internal = 80
    external = 8080
  }

  restart = "unless-stopped"
}

resource "docker_container" "nodejs" {
  name  = "nodejs"
  image = "node:20"

  volumes {
    host_path      = "C:/xampp/htdocs/projects/TP-INFRAASCODE/TP-InfraAsCode/tp-infra-as-code-final/app"
    container_path = "/usr/src/app"
  }

  working_dir = "/usr/src/app"

  command = ["node", "index.js"]

  networks_advanced {
    name = docker_network.devops_net.name
  }

  ports {
    internal = 3000
    external = 3000
  }

  restart = "unless-stopped"
}