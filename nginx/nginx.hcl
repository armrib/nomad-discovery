job "nginx-proxy" {
  datacenters = ["dc1"]
  type        = "system"

  update {
    stagger          = "10s"
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert      = false
    canary           = 0
  }

  group "nginx-proxy" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "nginx-proxy" {
      driver = "docker"

      config {
        image = "nginx"

        port_map {
          http = 8080
        }

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 10

          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "nginx-proxy"
        tags = ["nginx-proxy"]
        port = "http"

        check {
          name     = "nginx alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      template {
        data          = <<EOF
upstream nomad {
  server 127.0.0.1:4646;
}
upstream consul {
  server 127.0.0.1:8500;
}
upstream vault {
  server 127.0.0.1:8200;
}

server {
  listen 8080;
  server_name 8080-cs-305032714376-default.cs-europe-west1-onse.cloudshell.dev;

  location /nomad/ {
    proxy_pass http://127.0.0.1:4646;
  }

  location /consul/ {
    proxy_pass http://127.0.0.1:8500;
  }

  location /vault/ {
    proxy_pass http://127.0.0.1:8200;
  }
}
EOF
        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}