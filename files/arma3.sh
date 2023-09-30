#!/bin/bash
arma3folder='/root/Steam/steamapps/common/Arma*'
arma3exe=arma3server_x64
servercfg=server.cfg

function runcommand() {
        ./$arma3exe -config=$servercfg \
        -mod=$(ls | grep "@" | tr "\n" ";")
}

# change workdir
cd $arma3folder

# execute Arma3 server
echo Starting Arma3 Server
runcommand

# failsafe loop
for (( ; ; ))
do
   echo Arma3 Server is down
   sleep 10s

   echo Starting Arma3 Server again
   runcommand
done
