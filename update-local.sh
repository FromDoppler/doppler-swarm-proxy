docker stack rm doppler-swarm
docker build -t fromdoppler/sites-proxy:local sites-proxy/.
sleep 7
docker stack deploy -c docker-compose.yml --with-registry-auth doppler-swarm
sleep 15
docker stack ls
docker service ls
