log_level  = "WARN"
datacenter = "dc1"

# Advertise a bogus HTTP address to force the UI
# to fallback to streaming logs through the proxy.
advertise {
  http = "0.0.0.0:4646"
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

plugin "raw_exec" {
  config {
    enabled = true
  }
}
