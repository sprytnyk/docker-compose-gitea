#!/usr/bin/env sh

sudo rm /etc/docker/daemon.json
sudo sed -i -e 's/DEFAULT_FORWARD_POLICY="ACCEPT"/DEFAULT_FORWARD_POLICY="DROP"/g' /etc/default/ufw

sudo systemctl restart docker ufw
