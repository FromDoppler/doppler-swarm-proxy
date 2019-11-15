#!/bin/sh

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
set -u

# Lines added to get the script running in the script path shell context
# reference: http://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script/
cd $(dirname $0)

# To avoid issues with MINGW and Git Bash, see:
# https://github.com/docker/toolbox/issues/673
# https://gist.github.com/borekb/cb1536a3685ca6fc0ad9a028e6a959e3
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

docker stack rm doppler-swarm
docker build --build-arg version=local-$(date +"%Y%m%d_%H%M") -t fromdoppler/sites-proxy:local ../sites-proxy
sleep 7
docker-compose -f docker-compose.yml -f docker-compose-local.yml config > docker-stack.yml
docker stack deploy -c docker-stack.yml --with-registry-auth doppler-swarm
sleep 15
docker stack ls
docker service ls
