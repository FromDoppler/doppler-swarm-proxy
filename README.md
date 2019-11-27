# Doppler Swarm

Here we will store the configuration of our experimental Docker Swarm Architecture.

And probably here will define the image for _Doppler Swarm Proxy_ with the required configuration.

## Architecture

Draft:

![Doppler Swarm Network](docs/doppler-swarm-network.svg)

Probably, we will sign most of the requests in _doppler-swarm-proxy_, so _doppler-for_shopify_ and
_doppler-webapp_ are only exposing non-encrypted ports.

But, _doppler-forms_ has to deal with different and non-static keys, for that reason it is also
exposing a encrypted port.

## Usage

### Install prerequisites

Install _Docker_ in all nodes, configure the users and initialize it.

```bash
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io

sudo groupadd docker

sudo usermod -aG docker ${user}

newgrp docker

sudo systemctl enable docker
sudo systemctl stop docker
sudo systemctl start docker
```

See also:

* [Get Docker Engine - Community for CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
* [Post-installation steps for Linux](https://docs.docker.com/install/linux/linux-postinstall/)

### Create a swarm

Initialize the swarm with the first node as manager (by the moment `1042791-rabbitmq / 172.25.48.222`).

```bash
$ docker swarm init --advertise-addr 172.25.48.222
Swarm initialized: current node (9zap4vc1suo3bxsr4ohwm1wpi) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3ytm******************************************9u3b-eh8h*****************4zfn 172.25.48.222:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

See also:

* [Create a swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)

### Add another manager to the swarm

It is recommended having odd number of managers. If it is not possible having three, having one is better than two,
because if you have 2 and one of them goes down, the other one does not know that.

Get the join information from one of the existent swarm nodes (in our example `1042791-rabbitmq / 172.25.48.222`).

```bash
$ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3ytm******************************************9u3b-a6ii*****************itve 172.25.48.222:2377
```

Run the generated command line in the new node (in our example `1022851-mta.cloudspace / 172.24.16.221`).

```bash
docker swarm join --token SWMTKN-1-3ytm******************************************9u3b-a6ii*****************itve 172.25.48.222:2377
```

See also:

* [Add nodes to the swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/)

### Add a worker to the swarm

Get the join information from one of the existent swarm nodes (in our example `1042791-rabbitmq / 172.25.48.222`).

```bash
$ docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3ytm******************************************9u3b-eh8h*****************4zfn 172.25.48.222:2377
```

Run the generated command line in the new node.

```bash
docker swarm join --token SWMTKN-1-3ytm******************************************9u3b-eh8h*****************4zfn 172.25.48.222:2377
```

See also:

* [Add nodes to the swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/)

### Leave a swarm

If you have only two managers and leave the swarm, the other one will not work alone without an explicit command.

```bash
docker swarm leave
```

### Login

If I am not wrong, login is only required in one node.

To download images we are using the user `dnoyareader`.

**TODO:** We should learn about credential helpers.

```bash
$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you dont have a Docker ID, head over to https://hub.docker.com to create one.
Username: dnoyareader
Password:
WARNING! Your password will be stored unencrypted in /home/user1/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

### Prepare our swarm stack

We need to prepare a server with the files required by _docker stack deploy_.

In one of the swarm managers node run the following code (by the moment `1042791-rabbitmq / 172.25.48.222`).

```bash
sudo mkdir /doppler-swarm
sudo chgrp docker /doppler-swarm -R
sudo chmod g+ws doppler-swarm
cd /doppler-swarm
wget https://raw.githubusercontent.com/FromDoppler/doppler-swarm/master/swarm-stack/docker-compose.yml
# TODO: determine how to also download secrets and other files
# See files in: https://github.com/FromDoppler/doppler-swarm/tree/master/swarm-stack

$ docker stack deploy -c docker-compose.yml --with-registry-auth doppler-swarm
Creating network doppler-swarm_sites
Creating service doppler-swarm_doppler-webapp
Creating service doppler-swarm_doppler-docker-playground
Creating service doppler-swarm_doppler-forms
Creating service doppler-swarm_sites-proxy
```

### Remove our swarm stack

```bash
docker stack rm doppler-swarm
```

## Useful commands

### Access to a running container

Access into running container to inspect with bash commands inside.

```bash
docker exec -it doppler-swarm_sites-proxy.1.p5bffwi5c0nyy8hibr0j7z81u /bin/bash
```

### Run a image with bash in place of the default entry point

You could use this to access into a failing image to run bash commands inside to see what happened, get a detailed log.

```bash
docker run --rm -it --entrypoint=/bin/sh fromdoppler/doppler-forms:beta
```



## Drafts

```bash
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/inspect-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/scale-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/delete-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/delete-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/drain-node/
# Skipping https://docs.docker.com/engine/swarm/ingress/


docker login -u dnoyareader -p c56***d80

docker service create --name test-forms --publish published=80,target=80 --replicas 2 --with-registry-auth fromdoppler/doppler-forms:beta

# 2019-10-31
# In my local machine

$ docker swarm init
Swarm initialized: current node (x09r0qcwdx7q636822qmudg6r) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-1g2k7tvyy92zj4ou717c0xbn2tvi9wvs90d2v4badglpj9ezk7-exunjfpyed48qbf6mr694xkbg 192.168.65.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

# Update the image of the containers

$ docker service update --image fromdoppler/doppler-docker-playground:beta doppler-docker-playground
overall progress: 2 out of 2 tasks
1/2: running   [==================================================>]
2/2: running   [==================================================>]
verify: Service converged

# Enough manual micro-experiments, it continues in `update-local.sh`
```
