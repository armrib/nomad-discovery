log_level  = "WARN"
datacenter = "dc1"

advertise {
  http = "internal-ip:4646"
}

ui {
  enabled = true

  consul {
    ui_url = "/consul"
  }
}

client {
  enabled = true
}

server {
  enabled = true
}

consul {
  address = "127.0.0.1:8500"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
