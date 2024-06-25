#!/bin/bash

mkdir -p ~/.cloudshell
touch ~/.cloudshell/no-apt-get-warning

git config --global user.email "armrib88@google.com"
git config --global user.name "Armand Ribouillault"

sudo apt list | grep "\[installed\]" | grep -v "git\|lsb_release\|coreutils\|gpg\|sudo\|wget\|supervisor\|curl\|openssl\|google\|docker\|lib\|make\|apt\|auto" | cut -d/ -f1 | xargs sudo apt remove -y
sudo apt install wget gpg coreutils curl supervisor

if [ ! -f /etc/apt/sources.list.d/hashicorp.list ] && [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
fi

sudo apt update
sudo apt install -y nomad consul
sudo apt autoremove -y
nomad -v && consul -v || echo "nomad or consul not found"

curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$([ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

sudo sysctl -w net.bridge.bridge-nf-call-arptables=1
sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sudo sysctl -w net.bridge.bridge-nf-call-iptables=1

pwd=$(pwd)
sudo service supervisor start
(cd /etc/supervisor/conf.d/ && sudo ln -sf ${pwd}/configs/*.conf .)

echo done
