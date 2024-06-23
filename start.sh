#!/bin/bash

sudo supervisorctl reread
sudo supervisorctl update

sudo supervisorctl stop consul
sudo supervisorctl stop nomad

# sudo rm -rf nomad/tmp consul/tmp
# sudo mkdir -p nomad/tmp/plugins
# sudo mkdir -p nomad/tmp/alloc

sudo supervisorctl start consul
sudo supervisorctl start nomad
