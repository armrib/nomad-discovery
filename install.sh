#!/bin/bash

mkdir -p ~/.cloudshell && \
touch ~/.cloudshell/no-apt-get-warning

sudo apt list | grep "\[installed\]" | grep -v "git\|lsb_release\|coreutils\|gpg\|sudo\|wget" | cut -d/ -f1 | xargs -n1 sudo apt remove -y

# Download Nomad Linux
sudo apt update && \
sudo apt install wget gpg coreutils

if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
    sudo rm /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
fi

nomad -v && consul -v && vault -v && \
sudo apt update && \
sudo apt install nomad consul vault && \
sudo apt autoremove


# Post installation
if [ ! -f cni-plugins.tgz ]; then
    curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz && \
    sudo mkdir -p /opt/cni/bin && \
    sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

    echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables && \
    echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables && \
    echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

    sudo sysctl -w net.bridge.bridge-nf-call-arptables=1
    sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=1
    sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
fi

sudo ln -sf consul/consul.conf /etc/supervisor/conf.d/consul.conf
sudo ln -sf nomad/nomad.conf /etc/supervisor/conf.d/nomad.conf
sudo service supervisor start