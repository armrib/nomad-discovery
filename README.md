# Nomad Consul Vault Discovery

## Installation

To install:

```bash
bash install.sh
```

## Run
```bash
bash start.sh
```

## Commands
```bash
nomad fmt **/*.hcl

sudo supervisorctl restart nomad && sudo supervisorctl tail -f nomad

nomad run nginx/nginx.hcl && sleep 10 && nomad logs -f -job nginx

nomad run test.hcl
```

## References

- [Hashicorp Nomad](https://www.nomadproject.io/)
- [Hashicorp Consul](https://www.consul.io/)
- [Hashicorp Vault](https://www.vaultproject.io/)