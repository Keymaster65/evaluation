#!/bin/bash

export PATH="$PATH:$JAVA_HOME/bin"

_checkPoint(){
  export PATH="$PATH:$JAVA_HOME/bin"
  jcmd io.github.keymaster65.copper2go.vanilla.application.Main JDK.checkpoint
}

_wait(){
  typeset RC="1"
  while [ "$RC" != "0" ]; do
    echo "Waiting for service ..."
    curl --data Wolf http://localhost:59665/copper2go/3/api/twoway/2.0/Hello 2>&1 | fgrep "Hello Wolf"
    RC="$?"
  done
}

#sleep 3000

if [ ! -f "cr/cppath" ]; then
  echo "Starting to warm up at $(date +%H:%M:%S.%N)"
  export VANILLA_APPLICATION_OPTS="-XX:CRaCCheckpointTo=cr"
  bin/vanilla-application
  #_wait
  #_checkPoint
  sleep 5 # needed for checkpoint to complete
fi

echo "Starting with checkpoint at $(date +%H:%M:%S.%N)"
_wait &
java -XX:CRaCRestoreFrom=cr
