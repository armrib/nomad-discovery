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
        type     = "http"
        path     = "/"
        interval = "10s"
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
upstream backend {
{{ range nomadService "demo-webapp" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 8080;

   location /demo {
      proxy_pass http://backend;
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
