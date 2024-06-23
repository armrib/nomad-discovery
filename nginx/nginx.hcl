job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        network_mode = "host"
        image = "nginx"
        ports = ["http"]
        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
upstream nomad {
  server localhost:4646;
}
upstream consul {
  server localhost:8500;
}
upstream vault {
  server localhost:8200;
}
upstream demo {
  ip_hash;
{{ range service "demo" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
  listen 8080;

  location / {
    proxy_redirect ~^(http).?(://[^:]+):?\d*/(?!ui)(.*) /ui/$3;
    proxy_redirect ~^(https).?(://[^:]+):?\d*/(?!ui)(.*) /ui/$3;
    proxy_redirect ~^/(?!ui)(.*) /ui/$1;
  }
  
  location /ui {
    if ($http_referer ~ (/ui/nomad)) {
        proxy_pass http://nomad;
    }
    if ($http_referer ~ (/ui/consul)) {
        proxy_pass http://consul;
    }
    if ($http_referer ~ (/ui/vault)) { 
        proxy_pass http://vault;
    }
  }

  location /v1 {
    if ($http_referer ~ (/ui/nomad)) {
        proxy_pass http://nomad;
    }
    if ($http_referer ~ (/ui/consul)) {
        proxy_pass http://consul;
    }
    if ($http_referer ~ (/ui/vault)) {
        proxy_pass http://vault;
    }
  }

  location /ui/nomad {
    proxy_redirect ~^(http).?(://[^:]+):?\d*/(?!ui)(.*) /ui/$3;
    proxy_redirect ~^(https).?(://[^:]+):?\d*/(?!ui)(.*) /ui/$3;
    proxy_redirect ~^/(?!ui)(.*) /ui/$1;

    proxy_pass http://nomad;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
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
  
  location /ui/consul {
    proxy_pass http://consul;
  }

  location /ui/vault {
    proxy_pass http://vault;
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
