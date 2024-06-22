log_level = "INFO"
datacenter = "dc1"
data_dir = "/home/armand_ribouillault/nomad/vault/tmp/data"
address = "http://127.0.0.1:8201"
ui = true
storage "consul" {
    address = "127.0.0.1:8500"
    path    = "vault/"
}
listener "tcp" {
    address     = "0.0.0.0:8201"
    tls_disable = 1
}
