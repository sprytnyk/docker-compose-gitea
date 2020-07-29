#!/usr/bin/env sh
######################## Docker #########################################
#Update the apt package index and install packages to allow apt to use a
#repository over HTTPS
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update the apt package index, and install the latest version of Docker
# Engine and containerd
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Create the docker group
sudo groupadd docker

# Add your user to the docker group
sudo usermod -aG docker $USER

# TL;DR docker bypasses ufw firewall, so any rules you will apply for 80, 443
# ports simply won't work and they will be seen by the world
# See this to learn more:
# https://www.mkubaczyk.com/2017/09/05/force-docker-not-bypass-ufw-rules-ubuntu-16-04/
sudo sh -c 'cat > /etc/docker/daemon.json <<EOF
{"iptables": false}
EOF'

# Restart Docker to pick up changes from daemon.json
sudo systemctl restart docker
sudo systemctl status docker

######################## Docker Compose #################################
# Download the current stable release of Docker Compose
sudo curl -L \
	"https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
	-o /usr/local/bin/docker-compose

# Apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose

# Create a symbolic link to Docker Compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Test installation
docker --version
docker-compose --version
