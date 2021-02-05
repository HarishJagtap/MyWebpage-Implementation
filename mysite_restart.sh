#!/bin/sh
# Run this script as SU

WSGI_PATH="/var/www/MyWebpage/mywebsite"
SCRIPTS_PATH="/var/www/MyWebpage-Implementation/"

cd $SCRIPTS_PATH
./mysite_stop.sh

# Nginx Start
echo "Starting Nginx"
systemctl start nginx

# Wsgi start
echo "Starting Gunicorn"
cd $WSGI_PATH
gunicorn mywebsite.wsgi > /dev/null 2>&1 &
