#!/bin/bash

ROOT_PWD=$(pwd)

if [ ! -f .installed ]; then
    mkdir -p ~/.cloudshell
    touch ~/.cloudshell/no-apt-get-warning

    git config --global user.email "armrib88@google.com"
    git config --global user.name "Armand Ribouillault"

    sudo apt remove -y dotnet-runtime-5.0 dotnet-sdk-5.0 dotnet-sdk-6.0 dotnet-sdk-7.0 emacs-nox mercurial openjdk-11-jdk openjdk-17-jdk php-pear php7.4-bcmath php7.4-cgi php7.4-cli php7.4-dev php7.4-mbstring php7.4-mysql php7.4-xml powershell packages-microsoft-prod
    sudo apt install wget gpg coreutils curl

    if [ ! -f /etc/apt/sources.list.d/hashicorp.list ] && [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    fi

    sudo apt update
    sudo apt install -y nomad
    sudo apt autoremove -y
    nomad -v || (echo "nomad not found" && exit 1)

    nomad -autocomplete-install
    complete -C /usr/local/bin/nomad nomad

    sudo mkdir -p /opt/nomad
    sudo mkdir -p /etc/nomad.d
    sudo chmod 700 /opt/nomad /etc/nomad.d
    sudo ln -sf ${ROOT_PWD}/configs/*.hcl /etc/nomad.d/
    touch .installed
fi

if [ ! -f ./cni-plugins.tgz ]; then
    curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$([ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
    sudo mkdir -p /opt/cni/bin
    sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

    echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables
    echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
    echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

    sudo sysctl -w net.bridge.bridge-nf-call-arptables=1
    sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=1
    sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
fi

# NGINX reverse proxy for nomad UI
if [ ! -f /etc/nginx/conf.d/nomad_reverse_proxy.conf ]; then
    sudo ln -sf ${ROOT_PWD}/configs/nomad_reverse_proxy.conf /etc/nginx/conf.d/
    sudo service nginx restart
fi

echo done
