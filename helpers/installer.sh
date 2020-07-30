#!/usr/bin/env sh

# SSH Container Passthrough
sudo mkdir -p /app/gitea
sudo cp helpers/gitea /app/gitea/gitea

# Create git user, make its an owner of /var/lib/gitea, and log in
sudo adduser --gecos ""  --disabled-password --home /var/lib/gitea/git git
sudo chown git:git /var/lib/gitea

USER_PASSWORD="$(pwgen -s 20 -y)"
echo -e "Your password is \e[34m\"${USER_PASSWORD}\"\e[0m. \e[91mDON'T FORGET TO SAVE IT!\e[0m"
sudo -u git usermod --password "$(openssl passwd -1 "${USER_PASSWORD}")" "${USER_NAME}"

# Create SSH key pair for git user
sduo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key" -N '' -f "${HOME}/.ssh/id_rsa"

# Add host pub key to authorized_keys that will be shared between
# server container and the host git user
sudo -u git touch /var/lib/gitea/git/.ssh/authorized_keys
sudo -u git chmod 644 /var/lib/gitea/git/.ssh/authorized_keys
sudo -u git sh -c \
"echo \"no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(sudo -u git cat /var/lib/gitea/git/.ssh/id_rsa.pub)\" >> /var/lib/gitea/git/.ssh/authorized_keys"
