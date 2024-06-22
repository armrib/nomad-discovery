log_level  = "WARN"
datacenter = "dc1"
data_dir   = "/home/armand_ribouillault/nomad/nomad/tmp/data"
addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}
ui {
  enabled = true
  consul {
    ui_url = "http://127.0.0.1:8500/ui"
  }
  vault {
    ui_url = "http://127.0.0.1:8200/ui"
  }
}
client {
  enabled = true
}
server {
  enabled = true
}
consul {

}
vault {
  enabled = true
}
