#!/bin/bash

export PATH="$PATH:$JAVA_HOME/bin"
typeset logPrefix="============================="
_checkPoint(){
  export PATH="$PATH:$JAVA_HOME/bin"
  jcmd io.github.keymaster65.copper2go.vanilla.application.Main JDK.checkpoint
}

_wait(){
  typeset RC="1"
  echo "Waiting for service ..."
  while [ "$RC" != "0" ]; do
    curl --data Wolf http://localhost:59665/copper2go/3/api/twoway/2.0/Hello 2>&1 | fgrep "Hello Wolf"
    RC="$?"
  done
  echo "$logPrefix Service found at  $(date +%H:%M:%S.%N)"
  time curl --data Wolf http://localhost:59665/copper2go/3/api/twoway/2.0/Hello 2>&1 | fgrep "Hello Wolf"
}

if [ ! -f "cr/cppath" ]; then
  echo "$logPrefix Starting to warm up container at $(date +%H:%M:%S.%N)"
  export VANILLA_APPLICATION_OPTS="-XX:CRaCCheckpointTo=cr"
  bin/vanilla-application &
  _wait
  kill %1
  echo "$logPrefix Starting to warm up application at $(date +%H:%M:%S.%N)"
  bin/vanilla-application &
  _wait
  echo "Now warming up with 100 requests"
  for i in {1..100}; do
    curl --data Wolf http://localhost:59665/copper2go/3/api/twoway/2.0/Hello 2>&1 | fgrep -q "Hello Wolf"
  done
  _checkPoint
  while [ ! -f "cr/cppath" ]; do
    echo "Wait for checkpoint"
    sleep 1
   done
fi

echo "$logPrefix Starting with checkpoint at $(date +%H:%M:%S.%N)"
_wait &
java -XX:CRaCRestoreFrom=cr
