packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

source "docker" "webapp-docker" {
  image  = "ubuntu:20.04"
  commit = true
  changes = [
    "EXPOSE 80",
    "LABEL maintainer='ULRICH MONJI'",
    "ENTRYPOINT [\"/usr/sbin/nginx\", \"-g\", \"daemon off;\"]"
  ]
}

build {
  name = "webapp-docker"
  sources = [
    "source.docker.webapp-docker"
  ]
  provisioner "shell" {
    inline = [
      "apt-get update",
      "sleep 30",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y nginx git",
      "rm -Rf /var/www/html/*",
      "git clone https://github.com/diranetafen/static-website-example.git /var/www/html/",
    ]
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "local/webapp"
      tag        = ["1.0", "latest"]
    }
  }
}