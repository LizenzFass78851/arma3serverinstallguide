#!/bin/bash

arma3folder='/srv/steamlibrary/steamapps/common/arma3'
arma3workshop='/srv/steamlibrary/steamapps/common/arma3/steamapps/workshop/content/107410'
arma3exe='arma3server_x64'
servercfg='server.cfg'

mkdir -p $arma3workshop
mkdir -p $arma3folder/keys

runcommand() {
    ./$arma3exe -config=$servercfg -cpuCount=$(nproc) -nosound -mod="$(ls | grep "^@" | tr "\n" ";")"
}

createsymlinksformods() {
cd "$arma3workshop"
origmods=$(find "./" -type d -maxdepth 1 | sed 's#^./##g' | sed 's# #%20#g' | sed -e '1d')
for mod in ${origmods}; do
  ln -s "$(pwd)/$mod" "$arma3folder/@$mod"
done
cd "$arma3folder"
}

fixnotlowercase() {
cd "$arma3workshop"
find . -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
cd "$arma3folder"
}

copybikeys() {
cd "$arma3workshop"
bikeys=$(find "./" | grep "/keys/" | grep ".bikey")
for bikey in ${bikeys}; do
  cp $bikey $arma3folder/keys/
done
cd "$arma3folder"
}

# change workdir
cd $arma3folder

# handling with mods
createsymlinksformods
fixnotlowercase
copybikeys

# execute Arma3 server
echo "Starting Arma3 Server"
runcommand

# failsafe loop
while true; do
    echo "Arma3 Server is down"
    sleep 10s

    echo "Starting Arma3 Server again"

    # execute Arma3 server again
    runcommand
done
