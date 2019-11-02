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

## Log

### References

* `Server1` Name: `1042791-rabbitmq`, IP: `172.25.48.222`
* `Server2` Name: `1022851-mta.cloudspace`, IP: `172.24.16.221`
* `user1`, `user2`, `user3`: usernames of the server's administrator users

```bash
# In `Server1` and `Server2`
#
# Following https://docs.docker.com/install/linux/docker-ce/centos/

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io

# Following https://docs.docker.com/install/linux/linux-postinstall/

sudo groupadd docker

sudo usermod -aG docker user1
sudo usermod -aG docker user2
sudo usermod -aG docker user3

newgrp docker

sudo systemctl enable docker
sudo systemctl stop docker
sudo systemctl start docker

# In `Server1`
# Following https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/

$ docker swarm init --advertise-addr 172.25.48.222
Swarm initialized: current node (9zap4vc1suo3bxsr4ohwm1wpi) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-35***qb5-cdm***276 172.25.48.222:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

# Following https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/

# In `Server2`

docker swarm join --token SWMTKN-1-35***qb5-cdm***276 172.25.48.222:2377

# Quiero hacer los dos managers

# In `Server1`

$ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-35***qb5-eqv***ls3 172.25.48.222:2377

# In `Server2`

docker swarm leave
docker swarm join --token SWMTKN-1-35***qb5-eqv***ls3 172.25.48.222:2377

# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/inspect-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/scale-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/delete-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/delete-service/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/
# Skipping https://docs.docker.com/engine/swarm/swarm-tutorial/drain-node/
# Skipping https://docs.docker.com/engine/swarm/ingress/

# In `Service1` and `Server2`

$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you dont have a Docker ID, head over to https://hub.docker.com to create one.
Username: dnoyareader
Password:
WARNING! Your password will be stored unencrypted in /home/user1/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

# In any server

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

# Enough manual micro-experiments, it continues in `local-experiments/update.sh`
```
