#!/bin/bash

sudo service supervisor start

sudo cp -f consul/consul.conf /etc/supervisor/conf.d/
sudo cp -f vault/vault.conf /etc/supervisor/conf.d/
sudo cp -f nomad/nomad.conf /etc/supervisor/conf.d/

sudo supervisorctl reread
sudo supervisorctl update

sudo supervisorctl restart consul
sudo supervisorctl restart vault
sudo supervisorctl restart nomad