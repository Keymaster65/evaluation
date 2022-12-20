#!/bin/bash

#set -x

_checkPoint(){
  docker exec -ti crac-example-vanilla bash -c '$JAVA_HOME/bin/jcmd io.github.keymaster65.copper2go.vanilla.application.Main JDK.checkpoint'
}

_wait(){
  while [ "$(curl localhost:8080 2> /dev/null)" != "Hello World" ]; do
    echo "Waiting for service ..."
  done
}

_buildImage(){
  if [ ! -r temp/openjdk-17-crac+3_linux-x64.tar.gz ]; then
    echo "Need JDK file temp/openjdk-17-crac+3_linux-x64.tar.gz."
    exit 1
  fi
  echo "Build image"
  docker build . --target app -t crac-example-vanilla
}

_stopContainer() {
  docker ps | fgrep -q crac-example-vanilla
  typeset RC="$?"
  if [ "$RC" = "0" ]; then
    echo "Stop container"
    docker stop crac-example-vanilla > /dev/null 2>&1
  fi
}

_removeContainer() {
  docker container ls -a | fgrep -q crac-example-vanilla
  typeset RC="$?"
  if [ "$RC" = "0" ]; then
    echo "Remove container"
    docker rm crac-example-vanilla > /dev/null 2>&1
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
    --name crac-example-vanilla \
    --privileged \
    --mount source=cr,target=/home/app/cr \
    crac-example-vanilla
}

[ "-h" = "$1" -o "--help" = "$1" ] \
  && echo "Usage $(basename $0) [-h|--help|--skipImage|-s]" && exit 1

[ "-s" = "$1" -o "--skipImage" = "$1" ] \
  && typeset skip="1" \
  && shift \
  && echo "Skipping build image and remove volume, so no warmup and checkpoint creation needed."

[ "$*" = "" ] || echo "WARN: Ignore unknown options \"$*\"."

cd $(dirname $0)
_stopContainer
_removeContainer
_removeVolume
[ "$skip" = "1" ] || _buildImage || exit $?
_startContainer
