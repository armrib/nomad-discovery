#!/bin/bash

sudo service supervisor start

sudo cp -f nomad/consul/consul.conf /etc/supervisor/conf.d/
sudo cp -f nomad/vault/vault.conf /etc/supervisor/conf.d/
sudo cp -f nomad/nomad/nomad.conf /etc/supervisor/conf.d/

sudo supervisorctl reread
sudo supervisorctl update

sudo supervisorctl start consul
sudo supervisorctl start vault
sudo supervisorctl start nomad