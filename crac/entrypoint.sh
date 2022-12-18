#!/bin/bash

export PATH="$PATH:$JAVA_HOME/bin"

_checkPoint(){
  jcmd example-jetty-1.0-SNAPSHOT.jar JDK.checkpoint
}

_wait(){
  while [ "$(curl localhost:8080 2> /dev/null)" != "Hello World" ]; do
    echo "Waiting for service ..."
  done
}

if [ ! -f "cr/cppath" ]; then
  echo "Starting to warm up at $(date +%H:%M:%S.%N)"
  java -XX:CRaCCheckpointTo=cr -jar example-jetty-1.0-SNAPSHOT.jar &
  _wait
  _checkPoint
  sleep 5 # needed for checkpoint to complete
fi

echo "Starting with checkpoint at $(date +%H:%M:%S.%N)"
_wait &
java -XX:CRaCRestoreFrom=cr
