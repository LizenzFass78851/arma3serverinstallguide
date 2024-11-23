#!/bin/bash

arma3folder='/srv/steamlibrary/steamapps/common/arma3'
arma3exe='arma3server_x64'
servercfg='server.cfg'

runcommand() {
    ./$arma3exe -config=$servercfg -cpuCount=$(nproc) -mod="$(ls | grep "^@" | tr "\n" ";")"
}

fixnotlowercase() {
# high experimental
scanfiles=y
scandirs=y
mods=$(ls | grep "^@")
IFS=$'\n' # Set the internal field separator to line break
for mod in $mods; do
  cd "$mod"
  echo convert "$mod"
  echo change dir to $(pwd)
  if [ "$scanfiles" = "y" ]; then
    find ./ -type f | while read -r file; do
        echo convert file "$file" of mod "$mod"
        new_name=$(echo "$file" | tr 'A-Z' 'a-z')
        if [ "$file" != "$new_name" ]; then
          mv "$file" "$new_name"
        fi
    done
  fi
  if [ "$scandirs" = "y" ]; then
    find ./ -type d | while read -r dir; do
        echo convert dir "$dir" of mod "$mod"
        new_name=$(echo "$dir" | tr 'A-Z' 'a-z')
        if [ "$dir" != "$new_name" ]; then
          mv "$dir" "$new_name"
        fi
    done
  fi
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
    #fixnotlowercase

    # execute Arma3 server again
    runcommand
done
