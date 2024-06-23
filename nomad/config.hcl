log_level  = "WARN"
datacenter = "dc1"
# data_dir   = "/home/armand_ribouillault/nomad/nomad/tmp/data"
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
  address = "127.0.0.1:8500"
  retry {
    enabled = true
  }
}
