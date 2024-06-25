log_level  = "INFO"
datacenter = "dc1"
bind_addr = "0.0.0.0"

addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}

ports {
  http = 8080
  rpc  = 8181
  serf = 8282
}


ui {
  enabled = true
}

client {
  enabled = true
}

server {
  enabled = true
}

consul {
  address = "localhost:8500"
}
