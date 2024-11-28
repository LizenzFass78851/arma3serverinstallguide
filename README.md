# arma3serverinstallguide
- This is a short installation guide from an inexperienced arma 3 server maintainer that will make it easier to install arma3server on Linux (ubuntu or debian).

> [!WARNING]
> **Success not guaranteed**

### instructions for installing arma3server on linux (ubuntu or debian)
1. [install steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD#Package_From_Repositories)

Ubuntu
```bash
# To install SteamCMD the multiverse repository and x86 packages must be enabled.
sudo add-apt-repository multiverse; sudo dpkg --add-architecture i386; sudo apt update
sudo apt install steamcmd
```
    
Debian
```bash
# To install SteamCMD add the non-free repository and x86 packages must be enabled. In Debian 12 (Bookworm) the apt-add-repository command no longer works, so you will need to create a work-around # (See also: https://stackoverflow.com/questions/76688863/apt-add-repository-doesnt-work-on-debian-12).
sudo apt update; sudo apt install software-properties-common; sudo apt-add-repository non-free; sudo dpkg --add-architecture i386; sudo apt update
sudo apt install steamcmd
```

2. [Follow the following instructions to download arma3 via steamcmd](https://www-ionos-de.translate.goog/digitalguide/server/knowhow/arma-3-server-erstellen/?_x_tr_sl=de&_x_tr_tl=en&_x_tr_hl=de&_x_tr_pto=wapp) (do not start yet)

prepare
```bash
# create arma3 folder
mkdir -p /srv/steamlibrary/steamapps/common/arma3

# install deps
apt install net-tools rename -y

# fix path error
grep -qxF 'export PATH=$PATH:/usr/games' ~/.bashrc || \
  echo 'export PATH=$PATH:/usr/games' >> ~/.bashrc && \
  source ~/.bashrc

# execute steamcmd
steamcmd
```

on steamcmd
```bash
force_install_dir /srv/steamlibrary/steamapps/common/arma3
login username yourpassword
app_update 233780 validate
quit
```

3. [generate the servercfg](https://a3config.byjokese.com/) or use [this example](./files/server.cfg) and copy it to the arma3server main directory

for use this example
```bash
wget https://github.com/LizenzFass78851/arma3serverinstallguide/raw/refs/heads/main/files/server.cfg \
  -O /srv/steamlibrary/steamapps/common/arma3/server.cfg
```

4. Copy the [arma3 start script](./files/arma3.sh) into the arma3server main directory
```bash
wget https://github.com/LizenzFass78851/arma3serverinstallguide/raw/refs/heads/main/files/arma3.sh \
  -O /srv/steamlibrary/steamapps/common/arma3/arma3.sh
chmod +x /srv/steamlibrary/steamapps/common/arma3/arma3.sh
```

5. Install the [Systemctl Service](./files/arma3server.service)
```bash
wget https://github.com/LizenzFass78851/arma3serverinstallguide/raw/refs/heads/main/files/arma3server.service \
  -O /etc/systemd/system/arma3server.service
systemctl enable arma3server
```

6. then start the arma3 service via systemctl.
```bash
systemctl start arma3server
```

-----

### instructions for installing mods on arma3server
- To download and install the mods (e.g. [Audi RS3 sedan 2023](https://steamcommunity.com/sharedfiles/filedetails/?id=3190514797) with id `3190514797`), execute the following commands (stop the arma 3 server beforehand and start it again at the end with the commands mentioned in the q&a)

prepare
```bash
steamcmd
```

on steamcmd
```bash
force_install_dir /srv/steamlibrary/steamapps/common/arma3
login username yourpassword
workshop_download_item 107410 id_of_this_mod_from_steamworkshop validate
quit
```

-----

#### Q&A

- If there are any errors during execution or the Arma3 server is not accessible even though the Arma3 server service is started, the service log can be displayed using the following command.
```bash
journalctl -b -u arma3server
```

- To stop the server use the following command
```bash
systemctl stop arma3server
```

- To restart the server use the following command
```bash
systemctl restart arma3server
```

- To update the arma 3 server data, update the arma 3 server via steamcmd (stop the systemctl service first)

prepare
```bash
steamcmd
```

on steamcmd
```bash
force_install_dir /srv/steamlibrary/steamapps/common/arma3
login username yourpassword
app_update 233780
quit
```

