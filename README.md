# arma3serverinstallguide
- This is a short installation guide from an inexperienced arma 3 server maintainer that will make it easier to install arma3server on Linux (ubuntu).
#### Success not guaranteed

### instructions for installing arma3server on linux (ubuntu)
- [install steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD#Manually)
- [Follow the following instructions to download arma3 via steamcmd](https://www-ionos-de.translate.goog/digitalguide/server/knowhow/arma-3-server-erstellen/?_x_tr_sl=de&_x_tr_tl=en&_x_tr_hl=de&_x_tr_pto=wapp) (do not start yet)
- [generate the servercfg](https://a3config.byjokese.com/) and copy it to the arma3server main directory
- [Insert and activate the systemctl service](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units) with the [partially preconfigured template](./files/arma3server.service)
- Copy the [arma3 start script](./files/arma3.sh) into the appropriate directory
  - the directory for the arma3 start script, if different, also adapt it to [the systemctl service file](https://github.com/LizenzFass78851/arma3serverinstallguide/blob/3e3e4889deb3c6ab052f8dc6d118cf7e9fac993f/files/arma3server.service#L7) so that the script is also started
  - Check the arma3 start script to see whether [the directory](https://github.com/LizenzFass78851/arma3serverinstallguide/blob/3e3e4889deb3c6ab052f8dc6d118cf7e9fac993f/files/arma3.sh#L2) stored as a variable where the arma3 server is installed needs to be adjusted.
- then start the arma3 service via systemctl.
