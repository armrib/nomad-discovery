log_level  = "INFO"
datacenter = "dc1"
data_dir   = "/home/armrib88/nomad-discovery/configs/nomad"

# Advertise a bogus HTTP address to force the UI
# to fallback to streaming logs through the proxy.
advertise {
  http = "0.0.0.0:4646"
}

addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}

ui {
  enabled = true
}

client {
  enabled = true

  drain_on_shutdown {
    deadline           = "5m"
    force              = true
    ignore_system_jobs = true
  }

  options = {
    "driver.allowlist" = "docker,raw_exec"
  }
}

server {
  enabled = true
}

consul {
  address = "127.0.0.1:8500"

  server_service_name = "nomad"
  client_service_name = "nomad-client"

  auto_advertise   = true
  server_auto_join = true
  client_auto_join = true
}

autopilot {
  cleanup_dead_servers      = true
  last_contact_threshold    = "200ms"
  max_trailing_logs         = 250
  server_stabilization_time = "10s"
  enable_redundancy_zones   = false
  disable_upgrade_migration = false
  enable_custom_upgrades    = false
}


plugin "raw_exec" {
  config {
    enabled = true
  }
}
