#!/bin/bash
# Run this script as SU as ". mysite_fresh_start.sh"


NGINX_CONF_PATH="/etc/nginx/"
GIT_CLONE_PATH="/var/www/"
WSGI_PATH="/var/www/MyWebpage/mywebsite/"
DOMAIN="harish-jagtap.com"
DJANGO_SECRET_KEY='|Remove this and add Secret key|'

if [ "$DJANGO_SECRET_KEY" = '|Remove this and add Secret key|' ]; then
  echo "-------------ERROR----------------"
  echo "Set the DJANGO_SECRET_KEY variable to 'New secret key' before running this script"
  exit 1
fi


# Install packages
echo "-------------------------------Installing apt packages-------------------------------------------"
apt update
apt-get install nginx
apt-get install python3-pip
pip3 install gunicorn


# Nginx conf
echo "--------------------------Adding Nginx Configuration----------------------------------"
mkdir -p $NGINX_CONF_PATH
cp nginx.conf "${NGINX_CONF_PATH}nginx.conf"


# Git clone
echo "-------------------------------Cloning Webpage Repo---------------------------------------"
mkdir -p $GIT_CLONE_PATH
cd $GIT_CLONE_PATH
git clone https://github.com/HarishJagtap/MyWebpage.git


# MyWebpage setup
echo "------------------------------Setting up Django---------------------------------------"
cd "${GIT_CLONE_PATH}MyWebpage/"
pip3 install -r requirements.txt
cd mywebsite
SECRET_KEY="${DJANGO_SECRET_KEY}"
python3 manage.py collectstatic
python3 manage.py makemigrations
python3 manage.py migrate --run-syncdb
python3 manage.py createsuperuser


# Add Startup Service
echo "-----------------------------------Adding Startup Service------------------------------------"
cd "${GIT_CLONE_PATH}MyWebpage-Implementation"
cp mysite_start.service /etc/systemd/system/mysite_start.service
chmod ugo+x mysite_restart.sh
systemctl enable mysite_start


# Starting Nginx and Wsgi
echo "-------------------------------Starting Nginx and Wsgi-----------------------------------"
./mysite_restart.sh


# Certbot setup
echo "----------------------------Setting up Certbot-------------------------------------"
snap install core
snap refresh core
apt-get remove certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
snap set certbot trust-plugin-with-root=ok
snap install certbot-dns-route53
certbot certonly -a manual -i nginx -d $DOMAIN,"*.${DOMAIN}"
