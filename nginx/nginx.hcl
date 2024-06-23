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
    network {
      # mbits = 10

      port "http" {
        static = 8080
      }
    }
    task "nginx-proxy" {
      driver = "docker"

      config {
        image = "nginx"
        ports = ["http"]
        volumes = [
          "local:/etc/nginx/nginx.d",
        ]
      }

      resources {
        cpu    = 500
        memory = 256
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
upstream demo {
{{ range service "demo-webapp" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
  listen 8080;

  location / {
      proxy_pass http://demo;
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