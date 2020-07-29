#!/usr/bin/env sh

# SSH Container Passthrough
sudo mkdir -p /app/gitea
sudo cp helpers/gitea /app/gitea/gitea

# Create git user, make its an owner of /var/lib/gitea, and log in
sudo adduser --gecos "" --home /var/lib/gitea/git git
sudo chown git:git /var/lib/gitea

# Create SSH key pair for git user
sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key"

# Add host pub key to authorized_keys that will be shared between
# server container and the host git user
sudo -u git touch /var/lib/gitea/git/.ssh/authorized_keys
sudo -u git chmod 644 /var/lib/gitea/git/.ssh/authorized_keys
sudo -u git sh -c \
"echo \"no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(sudo -u git cat /var/lib/gitea/git/.ssh/id_rsa.pub)\" >> /var/lib/gitea/git/.ssh/authorized_keys"
