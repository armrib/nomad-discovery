job "nginx" {
  datacenters = ["dc1"]
  type        = "system"

  group "nginx" {
    count = 1

    network {
      port "http" {
        to = 8080
        static = 8080
      }
    }

    service {
      name     = "nginx"
      port     = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "nginx" {

      resources {
        cpu    = 50
        memory = 128
      }

      driver = "docker"

      config {
        network_mode = "host"
        image        = "nginx:alpine"
        ports        = ["http"]
        volumes = [
          "local:/etc/nginx/nginx.d"
        ]
      }

      template {
        data          = <<EOF
upstream nomad {
  server localhost:4646;
}

server {
  listen 8080;

  location / {
    proxy_pass http://nomad;

    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    # Nomad blocking queries will remain open for a default of 5 minutes.
    # Increase the proxy timeout to accommodate this timeout with an
    # additional grace period.
    proxy_read_timeout 310s;

    # Nomad log streaming uses streaming HTTP requests. In order to
    # synchronously stream logs from Nomad to NGINX to the browser
    # proxy buffering needs to be turned off.
    proxy_buffering off;

    # The Upgrade and Connection headers are used to establish
    # a WebSockets connection.
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # The default Origin header will be the proxy address, which
    # will be rejected by Nomad. It must be rewritten to be the
    # host address instead.
    proxy_set_header Origin "${scheme}://${proxy_host}";
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