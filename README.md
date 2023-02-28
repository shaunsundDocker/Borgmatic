# borgmatic

_Borgmatic for Raspberry Pi_

This is a Work in Progress. See https://gitlab.com/sunddocker/borgmatic for info

## Installation from Dockerfile

For deployment from the Dockerfile and/or docker-compose.yml file, follow these instructions.

### Setup local appdata

```
mkdir -p ~/Local/appdata/borgmatic/config ~/Local/appdata/borgmatic/keys ~/Local/appdata/borgmatic/logs
```

_You may want to add a restore path for restores and a data directory for backups._

### Create image and container

Setup buildx environment

docker buildx create --name omni --platform linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/arm/v7,linux/arm/v6,linux/arm64 --use --bootstrap
docker buildx use omni
docker buildx build --push \
--platform linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/arm/v7,linux/arm/v6,linux/amd64,linux/arm64 \
--tag shaunsund/borgmatic:s6 .


```
docker build -t sund/borgmatic:s6 .
docker-compose up -d
```

## Installation from Docker Hub

Pull from Docker Hub

```
docker pull sund/borgmatic
```
Create the container with the necessary binding for the volumes. Example:

```
appdataroot="/data/appdata/"

docker container run -d --hostname borgmatic --name borgmatic \
  --label com.centurylinklabs.watchtower.enable=$watchlabel \
  -m "$memlimit" \
  --tty \
  -e 'SHELL'='/bin/bash' \
  -e 'PATH'='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
  -e 'USR_ID=0' \
  -e 'GRP_ID=0' \
  -v '/':'/storage/':'ro' \
  -v "${appdataroot}borgmatic/config/":"/etc/borgmatic/":'rw' \
  -v "${appdataroot}borgmatic/sshkeys/":"/root/.ssh/":'rw' \
  -v "${appdataroot}borgmatic/restore/":"/restore/":'rw' \
  -v "${appdataroot}borgmatic/logs/":"/var/log":'rw' \
  --restart=unless-stopped \
  sund/borgmatic:latest
```

## Usage

The first start the container it will create:

```
├── config
│   ├── config.yaml
│   └── cron
├── keys
│   ├── id_rsa
│   └── id_rsa.pub
└── logs
```

Edit the ```cron``` and ```config.yaml``` as needed. Copy the ```id_rsa.pub``` to your repo.

In a shell in the container, init the repo if you need to. ```cat /etc/borgmatic/cron``` to verify that you have a borgmatic line. You can change the verbosity to '2' while you test the setup and accept the ssh key.

### Sources

https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/