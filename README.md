# arma3serverinstallguide
- This is a short installation guide from an inexperienced arma 3 server maintainer that will make it easier to install arma3server on Linux (ubuntu).
####Success not guaranteed

1. [install steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD#Manually)
2. [Follow the following instructions to download arma3 via steamcmd](https://www-ionos-de.translate.goog/digitalguide/server/knowhow/arma-3-server-erstellen/?_x_tr_sl=de&_x_tr_tl=en&_x_tr_hl=de&_x_tr_pto=wapp) (do not start yet)
3. [generate the servercfg](https://a3config.byjokese.com/) and copy it to the arma3server main directory
4. [Insert and activate the systemctl service](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units) with the [partially preconfigured template](./files/arma3server.service)
5. Copy the [arma3 start script](./files/arma3.sh) into the appropriate directory (also adapt this to the systemctl service file so that the script is also started)
6. then start the arma3 service via systemctl.