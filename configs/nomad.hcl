log_level  = "WARN"
datacenter = "dc1"

advertise {
  http = "internal-ip:4646"
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
