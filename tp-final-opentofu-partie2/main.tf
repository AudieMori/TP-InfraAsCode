terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "monitoring_net" {
  name = "monitoring-net"
}

resource "docker_volume" "prometheus_data" {
  name = "prometheus_data"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.monitoring_net.name
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }

    mounts {
    type      = "bind"
    source    = "C:/xampp/htdocs/projects/TP-INFRAASCODE/TP-InfraAsCode/tp-final-opentofu-partie2/prometheus.yml"
    target    = "/etc/prometheus/prometheus.yml"
    read_only = true
    }

  ports {
    internal = 9090
    external = 9090
  }
}

resource "docker_container" "podinfo" {
  name  = "podinfo"
  image = "stefanprodan/podinfo:latest"

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.monitoring_net.name
  }

  ports {
    internal = 8080
    external = 8080
  }
}

resource "docker_volume" "grafana_data" {
  name = "grafana_data"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"

  ports {
    internal = 3000
    external = 3000
  }

  # Attacher le volume
  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  # Attacher au réseau existant
  networks_advanced {
    name = "monitoring-net"
  }

  restart = "unless-stopped"
}

resource "docker_volume" "loki_data" {
  name = "loki_data"
}

resource "docker_container" "loki" {
  name  = "loki"
  image = "grafana/loki:latest"

  # Port exposé
  ports {
    internal = 3100
    external = 3100
  }

  # Volume pour stocker les données
  volumes {
    volume_name    = docker_volume.loki_data.name
    container_path = "/loki"
  }

  # Monter le fichier de config minimal
  volumes {
    host_path      = "C:/xampp/htdocs/projects/TP-INFRAASCODE/TP-InfraAsCode/tp-final-opentofu-partie2/loki-config.yaml"
    container_path = "/etc/loki/local-config.yaml"
    read_only      = true
  }

  # Attacher au réseau existant
  networks_advanced {
    name = "monitoring-net"
  }

  restart = "unless-stopped"
}