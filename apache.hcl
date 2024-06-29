job "apache" {
  datacenters = ["dc1"]
  type        = "service"

  group "apache" {
    count = 3

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "apache"
      port = "http"
      provider = "nomad"

      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "apache" {
      driver = "docker"

      config {
        image = "httpd:latest"
        ports = ["http"]
      }
    }
  }
}
