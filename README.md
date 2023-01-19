# docker-server
Repository for docker-compose files and setup for my docker server

## Installation
Start with running install.sh

It will create a common.env file for containers installations script to use further on as docker .env-file.

The filesyncbrowser contains three parts:

- Syncthing for syncing files between computers, mobiles and servers.

- Filebrowser to access these files via web browser.

- Photoview to better view photos.

These three are chosen due to the fact they work directly on the filesystem so backup of the actual data 

### Important notes
This is designed for few users since syncthing does not have the concept users and the admin have to manage each folder manually in addition to pointing to the correct folders in filebrowser and photoview.

### Customize install.sh
It contains the domain name and time zone.





## TODO
### 1.0
- [x] List all packages that should be installed in nextcloud in its install.sh
- [x] Vaultwarden
### 2.0
- [ ] Add media stack
- [ ] Add linux iso downloader to media stack
- [ ] Add VPN for iso downloader
### Misc.
- [ ] Enable update of common.env and .env in install-scripts
- [ ] Add homepage


