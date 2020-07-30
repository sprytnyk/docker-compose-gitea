# Docker Compose for Gitea with Letsencrypt

## Description

This repository assumes you have created a user that in `sudo` group, have 
DNS records configured for a VPS instance and using 
Ubuntu 18.04 but should work with other distributives as well besides
`make docker` target. That target specifically for Ubuntu versions. You can
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

|       Name        |     Container      |                         Description                          |    Example     |
| :---------------: | :----------------: | :----------------------------------------------------------: | :------------: |
|     DNS_NAME      | server/letsencrypt |                          DNS name.                           |  example.com   |
|       EMAIL       |    letsencrypt     | An email address to be linked with SSL certificate. It should be a real one because you may get on occasion notifications from letsencrypt if something wrong with certificates, etc. | user@email.com |
|    SECRET_KEY     |       server       | A secrect key to be used by Gitea internals. This should be strong key and no less than 60 characters. | Gy4b1lJYT2...  |
|   POSTGRES_USER   |     server/db      |                    A postgres user name.                     |     dummy      |
| POSTGRES_PASSWORD |     server/db      |                  A postgres user password.                   |   AYZQ2lmD9b   |
|    POSTGRES_DB    |     server/db      |                     A postgres db name.                      |      mydb      |

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

**IMPORTANT!!!** If you're going to use ufw to set up firewall rules then you
should invoke `make iptables` command after installed Docker. It will add
startup script to update iptables on reboot through cron job and configure
Docker to obey ufw rules.  
See this for explanation for in-depth explanation.
https://www.mkubaczyk.com/2017/09/05/force-docker-not-bypass-ufw-rules-ubuntu-16-04/

To finish the installation don't forget to set environment variables
and after `make install` log out a VPS and log in back to have the ability
use `docker` command without `sudo`.

```console
$ make iptables # if you want to have ufw complaint Docker and if not yet invoked
$ make install # bootstrap required things for Gitea
$ cd gitea
$ make b # build docker images and run it in a background
```

After this, you will be able to navigate your DNS address and see
Gitea with SSL cert. Simple as that.

Last but not least, if you want to set a dark theme globally then invoke
`make dark` after commands above.
