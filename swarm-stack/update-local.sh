docker stack rm doppler-swarm
docker build -t fromdoppler/sites-proxy:local ../sites-proxy
# In place of the previous line, I tried this:
#     docker-compose build
# Based on https://stackoverflow.com/questions/48396459/docker-swarm-build-configuration-in-docker-compose-file-ignored-during-stack#54448433
# but it does not work, it said: "sites-proxy uses an image, skipping"
sleep 7
docker-compose -f docker-compose.yml -f docker-compose-local.yml config > docker-stack.yml
docker stack deploy -c docker-stack.yml --with-registry-auth doppler-swarm
sleep 15
docker stack ls
docker service ls
