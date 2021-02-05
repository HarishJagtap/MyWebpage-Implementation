#!/bin/bash
# Run this script as SU

NGINX_CONF_PATH="/etc/nginx/"
GIT_CLONE_PATH="/var/www/"

# Remove certbot
echo "----------------------------Removing Certbot---------------------------"
snap remove certbot
snap remove core
snap remove certbot-dns-route53
unlink /usr/bin/certbot

# Remove Nginx
echo "--------------------------Removing Packages-------------------------------"
apt-get remove nginx
apt-get remove python3-pip
rm "${NGINX_CONF_PATH}nginx.conf"

# Remove Git Clone
echo "-------------------------Removing Git Clone------------------------------"
rm -rf "${GIT_CLONE_PATH}MyWebpage"

# Remove Startup service
echo "-----------------------Removing Startup service-------------------------"
systemctl disable mysite_start
rm /etc/systemd/system/mysite_start.service
