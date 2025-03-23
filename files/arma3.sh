#!/bin/bash

arma3folder='/srv/steamlibrary/steamapps/common/arma3'
arma3workshop='/srv/steamlibrary/steamapps/common/arma3/steamapps/workshop/content/107410'
arma3exe='arma3server_x64'
servercfg='server.cfg'

steamcmd_user=""
steamcmd_password=""

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

install_mods() {
    local mod_ids=$1
    if [[ -z "$mod_ids" ]]; then
        echo "Error: No mod IDs provided for installation."
        exit 1
    fi
    if [[ -z "$steamcmd_user" || -z "$steamcmd_password" ]]; then
        echo "Error: SteamCMD user and password are required."
        exit 1
    fi
    IFS=',' read -ra ids <<< "$mod_ids"
    echo "Logging into SteamCMD..."
    steamcmd +force_install_dir $arma3folder +login "$steamcmd_user" "$steamcmd_password" $(for mod_id in "${ids[@]}"; do echo "+workshop_download_item 107410 $mod_id validate"; done) +quit
    echo "All specified mods have been installed."
}

update_all_mods() {
    if [[ -z "$steamcmd_user" || -z "$steamcmd_password" ]]; then
        echo "Error: SteamCMD user and password are required."
        exit 1
    fi
    echo "Updating all mods..."
    cd "$arma3workshop"
    mod_dirs=$(find . -maxdepth 1 -type d | sed '1d')
    if [[ -z "$mod_dirs" ]]; then
        echo "No mods found to update."
        return
    fi
    echo "Logging into SteamCMD..."
    steamcmd +force_install_dir $arma3folder +login "$steamcmd_user" "$steamcmd_password" $(for mod_dir in $mod_dirs; do mod_id=$(basename "$mod_dir"); echo "+workshop_download_item 107410 $mod_id validate"; done) +quit
    echo "All mods have been updated."
}

update_gameserver() {
    if [[ -z "$steamcmd_user" || -z "$steamcmd_password" ]]; then
        echo "Error: SteamCMD user and password are required."
        exit 1
    fi
    if pgrep -x "$arma3exe" > /dev/null; then
        echo "Error: Arma 3 server is still running. Please stop it before updating."
        exit 1
    fi
    echo "Updating Arma 3 server..."
    steamcmd +force_install_dir $arma3folder +login "$steamcmd_user" "$steamcmd_password" +app_update 233780 validate +quit
}

print_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --steamcmd-user <username>       Specify the SteamCMD username."
    echo "  --steamcmd-password <password>   Specify the SteamCMD password."
    echo "  --install-mods <mod_ids>         Install specific mods by their Steam Workshop IDs (comma-separated)."
    echo "  --update-all-mods                Update all installed mods."
    echo "  --update-gameserver              Update the Arma 3 game server (requires server to be stopped)."
    echo "  --help, -?                       Display this help message."
    echo ""
    echo "Examples:"
    echo "  $0 --steamcmd-user myuser --steamcmd-password mypass --install-mods 123456789,987654321"
    echo "  $0 --steamcmd-user myuser --steamcmd-password mypass --update-all-mods"
    echo "  $0 --steamcmd-user myuser --steamcmd-password mypass --update-gameserver"
}

# Parameter processing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --steamcmd-user)
            steamcmd_user="$2"
            shift 2
            ;;
        --steamcmd-password)
            steamcmd_password="$2"
            shift 2
            ;;
        --install-mods)
            install_mods "$2"
            exit 0
            ;;
        --update-all-mods)
            update_all_mods
            exit 0
            ;;
        --update-gameserver)
            update_gameserver
            exit 0
            ;;
        --help|-?)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Use --help or -? to display usage information."
            exit 1
            ;;
    esac
done

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
