#!/bin/bash

export PATH="$PATH:$JAVA_HOME/bin"

_checkPoint(){
  jcmd example-jetty-1.0-SNAPSHOT.jar JDK.checkpoint
}

_wait(){
  echo "Waiting for service ..."
  typeset RC=1
  while [ "$RC" != "0" ]; do
    curl --data Wolf http://localhost:8080   2>&1 | fgrep "Hello World"
    RC="$?"
  done
}

if [ ! -f "cr/cppath" ]; then
  echo "Starting to warm up at $(date +%H:%M:%S.%N)"
  java -XX:CRaCCheckpointTo=cr -jar example-jetty-1.0-SNAPSHOT.jar &
  _wait
  _checkPoint
  while [ ! -f "cr/cppath" ]; do
    echo "Wait for checkpoint"
    sleep 1
   done
fi

echo "Starting with checkpoint at $(date +%H:%M:%S.%N)"
_wait &
java -XX:CRaCRestoreFrom=cr
