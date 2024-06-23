log_level  = "WARN"
datacenter = "dc1"
# data_dir   = "/home/armand_ribouillault/nomad-discovery/nomad/tmp/data"

advertise {
  http = "internal-ip:4646"
}

ui {
  enabled = true

  consul {
    ui_url = "https://8080-cs-305032714376-default.cs-europe-west1-onse.cloudshell.dev/ui/consul"
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
