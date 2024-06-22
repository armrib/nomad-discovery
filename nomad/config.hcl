log_level = "INFO"
datacenter = "dc1"
data_dir = "/home/armand_ribouillault/nomad/nomad/tmp/data"
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
    servers = ["localhost:4647"]
    options {
        "consul.auto_join" = "provider=local"
        "consul.datacenter" = "dc1"
        "consul.retry_interval" = "5s"
    }
}
server {
    enabled = true
    bootstrap_expect = 1
    retry_join = ["localhost:4646"]
}
consul {
    address = "localhost:8500"
}
vault {
    enabled = true
    address = "http://127.0.0.1:8201"

   # Only needed in servers when transioning from the token-based flow to
    # workload identities.
    create_from_role = "nomad-cluster"

    # Provide a default workload identity configuration so jobs don't need to
    # specify one.
    default_identity {
        aud  = ["vault.io"]
        env  = false
        file = true
        ttl  = "1h"
    }
}
