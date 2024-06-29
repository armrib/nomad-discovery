job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 1

    network {
      mode = "host"
      port "http" {
        static = 8080
      }
    }

    service {
      name         = "nginx"
      port         = "http"
      provider     = "nomad"
      address_mode = "host"

      check {
        type     = "tcp"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image        = "nginx:alpine"
        network_mode = "host"
        ports        = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
# Since WebSockets are stateful connections but Nomad has multiple
# server nodes, an upstream with ip_hash declared is required to ensure
# that connections are always proxied to the same server node when possible.
upstream nomad-ws {
    ip_hash;
    server localhost:4646;
}
upstream demo {
{{ range nomadService "demo" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}
upstream apache {
{{ range nomadService "apache" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 8080;

   location = /demo {
      proxy_pass http://demo;
   }
   location = /apache {
      proxy_pass http://apache;
   }
    location / {
        proxy_pass http://nomad-ws;
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
