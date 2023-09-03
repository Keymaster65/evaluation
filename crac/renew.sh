#!/bin/bash

#set -x

_buildImage(){
  if [ ! -r temp/zulu17.42.21-ca-crac-jdk17.0.7-linux_x64.tar.gz ]; then
    echo "Need JDK file temp/zulu17.42.21-ca-crac-jdk17.0.7-linux_x64.tar.gz."
    exit 1
  fi
  echo "Build image"
  dos2unix entrypoint.sh
  docker build . --target app -t crac-demo
}

_stopContainer() {
  docker ps | fgrep -q crac-demo
  typeset RC="$?"
  if [ "$RC" = "0" ]; then
    echo "Stop container"
    docker stop crac-demo > /dev/null 2>&1
  fi
}

_removeContainer() {
  docker container ls -a | fgrep -q crac-demo
  typeset RC="$?"
  if [ "$RC" = "0" ]; then
    echo "Remove container"
    docker rm crac-demo > /dev/null 2>&1
  fi
}

_removeVolume() {
  echo "Remove volume"
  docker volume  rm cr > /dev/null 2>&1
}

_startContainer() {
  echo "Start container"
  docker run \
    -p8080:8080 \
    -d \
    --name crac-demo \
    --privileged \
    --mount source=cr,target=/home/app/cr \
    crac-demo
}

[ "-h" = "$1" -o "--help" = "$1" ] \
&& echo "Usage $(basename $0) [-h|--help|--skipImage|-s]" && exit 1

[ "-s" = "$1" -o "--skipImage" = "$1" ] \
&& typeset skip="1" \
&& shift \
&& echo "Skipping build image."

[ "$*" = "" ] || echo "WARN: Ignore unknown options \"$*\"."

cd $(dirname $0)
_stopContainer
_removeContainer
_removeVolume
[ "$skip" = "1" ] || _buildImage || exit $?
_startContainer
