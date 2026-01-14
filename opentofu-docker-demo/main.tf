terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# =========================
# Réseau Docker
# =========================
resource "docker_network" "stack_network" {
  name = "api_stack_network"
}

# =========================
# Volumes persistants
# =========================
resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_volume" "redis_data" {
  name = "redis_data"
}

# =========================
# Images Docker
# =========================
resource "docker_image" "postgres" {
  name = "postgres:16"
}

resource "docker_image" "redis" {
  name = "redis:7"
}

resource "docker_image" "api" {
  name = "my-api:latest"
}

# =========================
# Conteneur PostgreSQL
# =========================
resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.postgres.name

  env = [
    "POSTGRES_DB=appdb",
    "POSTGRES_USER=appuser",
    "POSTGRES_PASSWORD=secret"
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.stack_network.name
  }
}

# =========================
# Conteneur Redis
# =========================
resource "docker_container" "redis" {
  name  = "redis"
  image = docker_image.redis.name

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.stack_network.name
  }
}

# =========================
# Conteneur API
# =========================
resource "docker_container" "api" {
  name  = "api"
  image = "nginx:latest"  # remplace my-api
  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.stack_network.name
  }

  depends_on = [
    docker_container.postgres,
    docker_container.redis
  ]
}
