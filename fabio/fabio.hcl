job "fabio" {
  datacenters = ["dc1"]

  group "fabio" {
    network {
      port "lb" {
        to = 9999
      }
      port "ui" {
        to = 8080
      }
    }
    task "fabio" {
      driver = "docker"
      config {
        image = "fabiolb/fabio"
        network_mode = "host"
        ports = ["lb","ui"]
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
