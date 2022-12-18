#!/bin/bash

#set -x

_checkPoint(){
  docker exec -ti crac-example-jetty bash -c '$JAVA_HOME/bin/jcmd example-jetty-1.0-SNAPSHOT.jar JDK.checkpoint'
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
  docker build . --target app -t crac-example-jetty
}

_stopContainer() {
  docker ps | fgrep -q crac-example-jetty
  typeset RC="$?"
  if [ "$RC" = "0" ]; then
    echo "Stop container"
    docker stop crac-example-jetty > /dev/null 2>&1
  fi
}

_removeContainer() {
  docker container ls -a | fgrep -q crac-example-jetty
  typeset RC="$?"
  if [ "$RC" = "0" ]; then
    echo "Remove container"
    docker rm crac-example-jetty > /dev/null 2>&1
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
    --name crac-example-jetty \
    --cap-add SYS_PTRACE \
    --security-opt seccomp:unconfined \
    --security-opt apparmor:unconfined \
    --privileged \
    --mount source=cr,target=/home/app/cr \
    crac-example-jetty
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
[ "$skip" = "1" ] || _removeVolume
[ "$skip" = "1" ] || _buildImage || exit $?
_startContainer
