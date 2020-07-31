# Docker Compose for Gitea with Letsencrypt

## Description

This repository assumes you have created a user that in `sudo` group, have 
DNS records configured for a VPS instance, VPS will have one Docker bridge if
you're going to use ufw with Docker (IMO it's simpler to use 
[binary setup](https://docs.gitea.io/en-us/install-from-binary/) than Dockerised
solution) and using Ubuntu 18.04 but should work with other distributives as well
besides `make docker` target. That target specifically for Ubuntu versions. You can
make use of this dummy script to bootstrap a user if still under `root` one:
[bootstrap.sh](https://gist.github.com/vald-phoenix/6db4bf3252be5dbd033b5f9346c52a29)

It's important to have proper UID and GID values for `server` and `lestencrypt`
containers. Default values the following:

- *letsencrypt* container has UID and GID values set to 1000
- *server* container has UID and GID values set to 1001

So if your VPS user has the following values:

```console
$ id
uid=1005(user) gid=1005(user) groups=1005(user),27(sudo)
```

Then you need to set in docker-compose values below otherwise skip this step:

- for letsencrypt container `PUID` and `PGID` to 1005
- for server container `USER_UID` and `USER_GID` to 1006

## Environment variables

In order to work properly it's required to set the following environment variables:

|       Name        |     Container      |                         Description                          |         Example          |
| :---------------: | :----------------: | :----------------------------------------------------------: | :----------------------: |
|     DNS_NAME      | server/letsencrypt |                          DNS name.                           |       example.com        |
|       EMAIL       |    letsencrypt     | An email address to be linked with SSL certificate. It should be a real one because you may get on occasion notifications from letsencrypt if something wrong with certificates, etc. |      user@email.com      |
|      STAGING      |    letsencrypt     | Letsencrypt will try first to get a certificate from the staging environment, so in case if we'll have some errors the limit won't be exceeded. See [rate limits](https://letsencrypt.org/docs/rate-limits/). |    Default to *true*     |
|    SECRET_KEY     |       server       | A secrect key to be used by Gitea internals. This should be strong key and no less than 60 characters. |      Gy4b1lJYT2...       |
|   POSTGRES_USER   |     server/db      |                    A postgres user name.                     |          dummy           |
| POSTGRES_PASSWORD |     server/db      |                  A postgres user password.                   |        AYZQ2lmD9b        |
|    POSTGRES_DB    |     server/db      |                     A postgres db name.                      |           mydb           |
|   PROJECT_PATH    |         -          | A path where is located project for start up script to launch docker-compose that will produce bridge interface, get its ip and apply firewall rule. You don't need to set this variable if you're not going to use ufw with Docker. | Default to *$HOME/gitea* |

For more customisation of environment variables see official docs for:

- [server container](https://docs.gitea.io/en-us/install-with-docker/#environments-variables)
- [letsencrypt container](https://github.com/linuxserver/docker-letsencrypt/blob/master/README.md#parameters)
- [db container](https://github.com/docker-library/docs/blob/master/postgres/README.md#environment-variables)

## Installation on a VPS

Launch such commands:

```console
$ sudo apt install make git pwgen # if not yet installed
$ git clone https://github.com/vald-phoenix/gitea.git
$ make docker # Ubuntu only
$ cd gitea
```

If not on Ubuntu then instead of `make docker` use these links:
- to install Docker https://docs.docker.com/engine/install/
- to install Docker Compose https://docs.docker.com/compose/install/

To finish the installation don't forget to set environment variables
and after `make install` log out a VPS and log in back to have the ability
use `docker` command without `sudo`.

```console
$ make install # bootstrap required things for Gitea
# log out - log in
$ cd gitea
```

The next step is to pull images, run docker compose and make
an attempt to get a letsencrypt certificate from the staging environment.

```console
$ export STAGING=true
$ make b
$ docker logs -f gitea_letsencrypt_1
```

And you should be able to see something like this:

```
Created donoteditthisfile.conf
NOTICE: Staging is active
No subdomains defined
E-mail address entered: user@email.com
http validation is selected
Generating new certificate
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for example.com
Waiting for verification...
Cleaning up challenges
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/example.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/example.com/privkey.pem
   Your cert will expire on 2020-10-29. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

New certificate generated; starting nginx
```

After this we're ready to get a real certificate from the prod environment:

```console
$ export STAGING=false
$ make down # if compose runs
$ docker volume rm gitea_letsencrypt # to delete staging certificates
$ make b
# you will be able to see similar output to the above if everything went fine
$ docker logs -f gitea_letsencrypt_1
```

After this, you will be able to navigate your DNS address and see
Gitea with SSL cert.

Last but not least, if you want to set a dark theme globally then invoke
`make dark` after commands above and restart server container.

That's it if you're not going to use ufw with Docker.

If you're going to use ufw to set up firewall rules then you
should invoke `make iptables`. It will add startup script to update iptables on
reboot through cron job and configure Docker to obey ufw rules. So if you want 
to limit ports 80, 443 for specific IPs then you need this.
See this for explanation for in-depth explanation.
https://www.mkubaczyk.com/2017/09/05/force-docker-not-bypass-ufw-rules-ubuntu-16-04/

```console
$ make iptables # if you want to have ufw compliant Docker
$ make ri # update iptables with bridge ip, compose should be running
```

One more crucial thing, if you need to stop all containers i.e.
`docker-compose down` then `docker-compose up -d` should be accompanied
with `make ri`. Docker bridge IP changes on occasion, so you want to
be sure that containers can communicate with the world.

When expiry of a certificate date is approaching then invoke the following
commands (ufw only):

```console
$ make uniptables
$ make down
$ make b
$ make iptables
$ make ri
```
