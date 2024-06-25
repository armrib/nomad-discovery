#!/bin/bash

sudo supervisorctl reread
sudo supervisorctl update

sudo supervisorctl stop consul
sudo supervisorctl stop nomad

sudo supervisorctl start consul
sudo supervisorctl start nomad