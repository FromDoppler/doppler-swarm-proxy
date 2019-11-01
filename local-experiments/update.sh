docker stack rm doppler-swarm
docker build -t fromdoppler/sites-proxy:beta ../sites-proxy/.
sleep 7
docker stack deploy -c ../docker-compose.yml --with-registry-auth doppler-swarm
sleep 15
docker stack ls
docker service ls

# I have updated hosts file with this:
#
#     127.0.0.1       localhost play.fromdoppler.com app.fromdoppler.com dopplerpages.com
#

echo http://localhost
curl http://localhost
echo http://play.fromdoppler.com
curl http://play.fromdoppler.com
echo http://app.fromdoppler.com
curl http://app.fromdoppler.com
echo http://dopplerpages.com
curl http://dopplerpages.com
echo http://127.0.0.1
curl http://127.0.0.1

docker service ls