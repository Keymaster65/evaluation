#!/bin/bash

#set -x

_buildImage(){
  if [ ! -r temp/zulu21.28.89-ca-crac-jdk21.0.0-linux_x64.tar.gz ]; then
    echo "Need JDK file temp/zulu21.28.89-ca-crac-jdk21.0.0-linux_x64.tar.gz."
    exit 1
  fi
  echo "Build image"
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
    -p59665:59665 \
    -d \
    --name crac-demo \
    --privileged \
    --mount source=cr,target=/home/app/cr \
    -e LOG_LEVEL_WORKFLOW=WARN \
    -e LOG_LEVEL_COPPER2GO=WARN    \
    -e LOG_LEVEL_COPPER=WARN \
    -e C2G_CONFIG="$(cat config.json)"     \
    crac-demo
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
