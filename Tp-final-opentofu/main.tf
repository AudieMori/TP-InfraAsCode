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

resource "docker_volume" "gitea_data" {
  name = "gitea_data"
}

resource "docker_container" "gitea" {
  name  = "gitea"
  image = "gitea/gitea:latest"

  networks_advanced {
    name = docker_network.devops_net.name
  }

  env = [
    "USER_UID=1000",
    "USER_GID=1000",
    "GITEA__database__DB_TYPE=postgres",
    "GITEA__database__HOST=postgres:5432",
    "GITEA__database__NAME=app_db",
    "GITEA__database__USER=app_user",
    "GITEA__database__PASSWD=app_password"
  ]

  volumes {
    volume_name    = docker_volume.gitea_data.name
    container_path = "/data"
  }

  ports {
    internal = 3000
    external = 3000
  }

  depends_on = [
    docker_container.postgres
  ]
}

resource "docker_volume" "jenkins_data" {
  name = "jenkins_data"
}

resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = "jenkins/jenkins:lts-jdk21"

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.devops_net.name
  }

  volumes {
    volume_name    = docker_volume.jenkins_data.name
    container_path = "/var/jenkins_home"
  }

  ports {
    internal = 8080
    external = 8080
  }

  depends_on = [
    docker_network.devops_net
  ]
}

resource "docker_volume" "sonarqube_data" {
  name = "sonarqube_data"
}

resource "docker_container" "sonarqube" {
  name  = "sonarqube"
  image = "sonarqube:community"

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.devops_net.name
  }

  env = [
    "SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/app_db",
    "SONAR_JDBC_USERNAME=app_user",
    "SONAR_JDBC_PASSWORD=app_password"
  ]

  volumes {
    volume_name    = docker_volume.sonarqube_data.name
    container_path = "/opt/sonarqube/data"
  }

  ports {
    internal = 9000
    external = 9000
  }

  depends_on = [
    docker_container.postgres
  ]
}