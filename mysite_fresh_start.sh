#!/bin/sh
# Run this script as SU

NGINX_CONF_PATH="/etc/nginx/"
GIT_CLONE_PATH="/var/www/"
WSGI_PATH="/var/www/MyWebpage/mywebsite/"
DOMAIN="harish-jagtap.com"
DJANGO_SECRET_KEY="" |Remove this and add Secret key|

# Install packages
echo "Installing apt packages"
apt update
apt-get install nginx
apt-get install python3-pip
pip3 install gunicorn

# Nginx conf
echo "Adding Nginx Configuration"
mkdir -p $NGINX_CONF_PATH
cp nginx.conf "${NGINX_CONF_PATH}nginx.conf"

# Git clone
mkdir -p $GIT_CLONE_PATH
cd $GIT_CLONE_PATH
git clone https://github.com/HarishJagtap/MyWebpage.git

# MyWebpage setup
echo "Setting up Django"
cd "${GIT_CLONE_PATH}MyWebpage/"
pip3 install -r requirements.txt
cd mywebsite
set SECRET_KEY=$DJANGO_SECRET_KEY
python manage.py collectstatic
python manage.py makemigrations
python manage.py migrate --run-syncdb
python manage.py createsuperuser

# Certbot setup
echo "Setting up Certbot"
snap install core
snap refresh core
apt-get remove certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
snap set certbot trust-plugin-with-root=ok
snap install certbot-dns-route53
certbot certonly -a manual -i nginx -d $DOMAIN,"*.${DOMAIN}"

# Add Startup Service
echo "Adding Startup Service"
cd "${GIT_CLONE_PATH}MyWebpage-Implementation"
cp mysite_start.service /etc/systemd/system/mysite_start.service
chmod ugo+x mysite_restart.sh
systemctl enable mysite_start
