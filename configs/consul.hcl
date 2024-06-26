log_level  = "INFO"
datacenter = "dc1"
data_dir   = "/home/armrib88/nomad-discovery/configs/consul"

client_addr    = "0.0.0.0"
advertise_addr = "127.0.0.1"

server = true

ui_config {
  enabled = true
}

connect {
  enabled = true
}