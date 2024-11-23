#!/bin/bash

arma3folder='/srv/steamlibrary/steamapps/common/arma3'
arma3workshop='$arma3folder/steamapps/workshop/content/107410'
arma3exe='arma3server_x64'
servercfg='server.cfg'

runcommand() {
    ./$arma3exe -config=$servercfg -cpuCount=$(nproc) -mod="$(ls | grep "^@" | tr "\n" ";")"
}

createsymlinksformods() {
if [ -d "$arma3workshop" ]; then
  cd "$arma3workshop"
  origmods=$(ls)
  IFS=$'\n' # Set the internal field separator to line break
  for mod in $origmods; do
    ln -s "$mod" "$arma3folder/@$mod"
  done
  cd "$arma3folder"
fi

}

fixnotlowercase() {
if [ -d "$arma3workshop" ]; then
  cd "$arma3workshop"
  find . -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
  cd "$arma3folder"
fi
}

# change workdir
cd $arma3folder

# create mod symlinks
createsymlinksformods

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
