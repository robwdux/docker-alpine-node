# docker-alpine-node

Build node with npm from source on Alpine Linux

## ...start your Dockerfile

```shell
FROM robwdux/alpine-node
```

### Lineage
[robwdux/alpine-node](https://github.com/robwdux/docker-alpine-node/README.md)
### [robwdux/alpine-init](https://github.com/robwdux/docker-alpine-init/README.md)
## [robwdux/alpine-base](https://github.com/robwdux/docker-alpine-base/README.md)

### Build or run with docker-compose
```shell
# add short alias for docker-compose
echo "alias dc='docker-compose '" >> ~/.bashrc && source ~/.bashrc

# the repo
git clone https://github.com/robwdux/docker-alpine-node.git

cd docker-alpine-node/

# build and run (image doesn't exist locally)
dc run --rm -ti node bash

# build explicitly
dc build

# build with meta data via build args for git info
sudo ./build.sh

# view meta data
$ docker inspect --format '{{ json .Config.Labels }}' robwdux/alpine-node:6.2.2 | jq
```
## Build a specific version, such as an LTS
```shell
$ NODE_VERSION=4.4.7
$ sudo docker build --build-arg NODE_VERSION=${NODE_VERSION} \
  -t robwdux/alpine-node:${NODE_VERSION} .
```

## Test Drive

### quick start with node repl
```shell
# assuming current user is a member of the docker group and the docker-compose alias exists
$ dc pull && dc run --rm -ti node
Creating network "dockeralpinenode_default" with the default driver
[s6-init] making user provided files available at /var/run/s6/etc...exited 0.
[s6-init] ensuring user provided files have correct perms...exited 0.
[fix-attrs.d] applying ownership & permissions fixes...
[fix-attrs.d] done.
[cont-init.d] executing container initialization scripts...
[cont-init.d] done.
[services.d] starting services
[services.d] done.
> process.exit()
/usr/bin/node exited 0
[cont-finish.d] executing container finish scripts...
[cont-finish.d] done.
[s6-finish] syncing disks.
[s6-finish] sending all processes the TERM signal.
[s6-finish] sending all processes the KILL signal and exiting.
```

### shell in interactively
```shell
sudo docker run --rm -ti \
                --name node \
                robwdux/alpine-node \
                bash
```
### shell into a daemonized running container
```shell
sudo docker run -d \
                --name node \
                robwdux/alpine-node \
                ping 8.8.8.8 && \
sudo docker exec -ti node bash
```
