#!/bin/bash

sudo service supervisor start

sudo cp -f consul/consul.conf /etc/supervisor/conf.d/
# sudo cp -f vault/vault.conf /etc/supervisor/conf.d/
sudo cp -f nomad/nomad.conf /etc/supervisor/conf.d/

sudo supervisorctl reread
sudo supervisorctl update

sudo supervisorctl stop consul
# sudo supervisorctl stop vault
sudo supervisorctl stop nomad

sudo rm -rf nomad/tmp consul/tmp
sudo mkdir -p nomad/tmp/plugins
sudo mkdir -p nomad/tmp/alloc

sudo supervisorctl start consul
# sudo supervisorctl start vault
sudo supervisorctl start nomad