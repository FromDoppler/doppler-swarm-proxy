#!/bin/sh

commit=$1
version=$2
versionPre=$3
# Examples:
#   sh build-n-publish.sh 94f85efb9c3689f409104ef7cde6813652ca59fb v12.34.5
#   sh build-n-publish.sh 94f85efb9c3689f409104ef7cde6813652ca59fb v12.34.5 beta1 # it is a pre-release
#   sh build-n-publish.sh 94f85efb9c3689f409104ef7cde6813652ca59fb v12.34.5 pr123 # it is a pre-release


if [ -z ${commit} ]
then
  echo "Missing commit (1st parameter)"
  exit 1
fi
if [ -z ${version} ]
then
  echo "Missing version (2nd parameter)"
  exit 1
fi

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

versionBuild=${commit}
# Ugly code to deal with versions
# Input:
#   version=v12.34.5
#   versionBuild=94f85efb9c
#   versionPre=0pr
# Output:
#   preReleasePrefix= "pre-" | ""
#   versionMayor=v12
#   versionMayorMinor=v12.34
#   versionMayorMinorPatch=v12.34.5
#   versionMayorMinorPatchPre=v12.34.5-0pr
#   versionFull=v12.34.5-0pr+94f85efb9c
#   versionFullForTag=v12.34.5-0pr_94f85efb9c
# region Ugly code to deal with versions

versionFull=${version}

if [ ! -z ${versionPre} ]
then
  versionFull=${versionFull}-${versionPre}
fi

if [ ! -z ${versionBuild} ]
then
  versionFull=${versionFull}+${versionBuild}
fi

# https://semver.org/spec/v2.0.0.html#backusnaur-form-grammar-for-valid-semver-versions
# <valid semver> ::= <version core>
#                  | <version core> "-" <pre-release>
#                  | <version core> "+" <build>
#                  | <version core> "-" <pre-release> "+" <build>
#
# <version core> ::= <major> "." <minor> "." <patch>
versionBuild="$(echo ${versionFull}+ | cut -d'+' -f2)"
versionMayorMinorPatchPre="$(echo ${versionFull} | cut -d'+' -f1)" # v0.0.0-xxx (ignoring `+` if exists)
versionPre="$(echo ${versionMayorMinorPatchPre}- | cut -d'-' -f2)"
versionMayorMinorPatch="$(echo ${versionMayorMinorPatchPre} | cut -d'-' -f1)" # v0.0.0 (ignoring `-` if exists)
versionMayor="$(echo ${versionMayorMinorPatch} | cut -d'.' -f1)" # v0
versionMinor="$(echo ${versionMayorMinorPatch} | cut -d'.' -f2)"
versionMayorMinor=${versionMayor}.${versionMinor} # v0.0
versionPatch="$(echo ${versionMayorMinorPatch} | cut -d'.' -f3)"

if [ -z ${versionBuild} ]
then
  versionFullForTag=${versionMayorMinorPatchPre}
else
  versionFullForTag=${versionMayorMinorPatchPre}_${versionBuild}
fi

if [ ! -z ${versionPre} ]
then
  preReleasePrefix="pre-"
else
  preReleasePrefix=""
fi
# endregion Ugly code to deal with versions

imageName=fromdoppler/sites-proxy
canonicalTag=${preReleasePrefix}${versionFullForTag}

docker build \
    -t ${imageName}:${canonicalTag} \
    --build-arg version=${preReleasePrefix}${versionFull} \
    .

docker tag ${imageName}:${canonicalTag} ${imageName}:${preReleasePrefix}${versionMayor}
docker tag ${imageName}:${canonicalTag} ${imageName}:${preReleasePrefix}${versionMayorMinor}
docker tag ${imageName}:${canonicalTag} ${imageName}:${preReleasePrefix}${versionMayorMinorPatch}
docker tag ${imageName}:${canonicalTag} ${imageName}:${preReleasePrefix}${versionMayorMinorPatchPre}

# TODO: It could break concurrent deployments with different docker accounts
docker login -u="$DOCKER_WRITTER_USERNAME" -p="$DOCKER_WRITTER_PASSWORD"

docker push ${imageName}:${canonicalTag}
docker push ${imageName}:${preReleasePrefix}${versionMayorMinorPatchPre}
docker push ${imageName}:${preReleasePrefix}${versionMayorMinorPatch}
docker push ${imageName}:${preReleasePrefix}${versionMayorMinor}
docker push ${imageName}:${preReleasePrefix}${versionMayor}