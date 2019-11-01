#!/bin/sh

label=$1
dockerhub_writter_username=$DOCKER_WRITTER_USERNAME
dockerhub_writter_password=$DOCKER_WRITTER_PASSWORD

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

# TODO: It could break concurrent deployments with different docker accounts
docker login -u="$dockerhub_writter_username" -p="$dockerhub_writter_password"

# TODO: using tag beta by the moment
docker build --pull \
    -t fromdoppler/sites-proxy:$label \
    ./sites-proxy/

docker push fromdoppler/sites-proxy:$label
