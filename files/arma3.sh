#!/bin/bash

arma3folder='/srv/steamlibrary/steamapps/common/arma3'
arma3exe='arma3server_x64'
servercfg='server.cfg'

runcommand() {
    ./$arma3exe -config=$servercfg -cpuCount=$(nproc) -mod="$(ls | grep "^@" | tr "\n" ";")"
}

fixnotlowercase() {
    for mod in $(ls | grep "^@"); do
        cd "$mod"
        find . -type f | while read -r file; do
            mv "$file" "$(echo $file | tr '[:upper:]' '[:lower:]')"
        done
        cd ..
    done
}

# change workdir
cd $arma3folder

# execute Arma3 server
echo "Starting Arma3 Server"
runcommand

# failsafe loop
while true; do
    echo "Arma3 Server is down"
    sleep 10s

    echo "Starting Arma3 Server again"

    # fix not lowercase problem
    fixnotlowercase

    # execute Arma3 server again
    runcommand
done
