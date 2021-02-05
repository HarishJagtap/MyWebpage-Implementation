#!/bin/bash
# Run this script as SU


NGINX_CONF_PATH="/etc/nginx/"
GIT_CLONE_PATH="/var/www/"

WSGI_PATH="/var/www/MyWebpage/mywebsite/"
SCRIPTS_PATH="/var/www/MyWebpage-Implementation/"

DOMAIN="harish-jagtap.com"
DJANGO_SECRET_KEY='|Remove this and add Secret key|'


if [ "$DJANGO_SECRET_KEY" = '|Remove this and add Secret key|' ]; then
  echo "ERROR:"
  echo "Set the DJANGO_SECRET_KEY variable to 'New secret key' before running this script"
  exit 1
fi

if [ "$1" = '--help' ]; then
  echo ""
  echo "Available options"
  echo ""
  echo "  -install-apt-packages"
  echo "  -add-temp-nginx-config"
  echo "  -add-nginx-config"
  echo "  -clone-repo"
  echo "  -setup-django"
  echo "  -add-startup-service"
  echo "  -setup-certbot"
  echo "  -init"
  echo "  -restart-site"
  echo "  -stop-site"
  echo "  -cleanup"
  echo ""

elif [ "$1" = "-install-apt-packages" ]; then
  install_packages()
  
elif [ "$1" = "-add-temp-nginx-config" ]; then
  temp_nginx_conf()
  
elif [ "$1" = "-add-nginx-config" ]; then
  nginx_conf()

elif [ "$1" = "-clone-repo" ]; then
  git_clone()

elif [ "$1" = "-setup-django" ]; then
  myWebpage_setup()

elif [ "$1" = "-add-startup-service" ]; then
  add_startup_service()
  
elif [ "$1" = "-setup-certbot" ]; then
  certbot_setup()
  
elif [ "$1" = "-init" ]; then
  init()
  
elif [ "$1" = "-restart-site" ]; then
  restart_website()
  
elif [ "$1" = "-stop-site" ]; then
  stop_website()
  
elif [ "$1" = "-cleanup" ]; then
  cleanup()

fi


install_packages() {
  echo "-------------------------------Installing apt packages-------------------------------------------"
  apt update
  apt-get install nginx
  apt-get install python3-pip
  pip3 install gunicorn
}

nginx_conf() {
  echo "--------------------------Adding Nginx Configuration----------------------------------"
  cd $SCRIPTS_PATH
  mkdir -p $NGINX_CONF_PATH
  cp nginx.conf "${NGINX_CONF_PATH}nginx.conf"
}

temp_nginx_conf() {
  echo "--------------------------Adding Temporary HTTP Nginx Configuration----------------------------------"
  cd $SCRIPTS_PATH
  mkdir -p $NGINX_CONF_PATH
  cp nginx_temp.conf "${NGINX_CONF_PATH}nginx.conf"
}

git_clone() {
  echo "-------------------------------Cloning Webpage Repo---------------------------------------"
  mkdir -p $GIT_CLONE_PATH
  cd $GIT_CLONE_PATH
  git clone https://github.com/HarishJagtap/MyWebpage.git
}

myWebpage_setup() {
  echo "------------------------------Setting up Django---------------------------------------"
  cd "${GIT_CLONE_PATH}MyWebpage/"
  pip3 install -r requirements.txt
  cd mywebsite
  export SECRET_KEY="${DJANGO_SECRET_KEY}"
  python3 manage.py collectstatic
  python3 manage.py makemigrations
  python3 manage.py migrate --run-syncdb
  python3 manage.py createsuperuser
}

add_startup_service() {
  echo "-----------------------------------Adding Startup Service------------------------------------"
  cd $SCRIPTS_PATH
  cp mysite_start.service /etc/systemd/system/mysite_start.service
  chmod ugo+x *.sh
  systemctl enable mysite_start
}

certbot_setup() {
  echo "----------------------------Setting up Certbot-------------------------------------"
  snap install core
  snap refresh core
  apt-get remove certbot
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot
  snap set certbot trust-plugin-with-root=ok
  snap install certbot-dns-route53
  certbot certonly -a manual -i nginx -d $DOMAIN,"*.${DOMAIN}"
}

init() {
  echo "-----------------------------Initialising--------------------------------------"
  apt-get install dos2unix
  
  cd $SCRIPTS_PATH
  chmod ugo+x *.sh
  dos2unix *
}

restart_website() {
  echo "---------------------------Restarting website-------------------------------------"
  stop_website

  echo "Starting Nginx"
  systemctl start nginx

  echo "Starting Gunicorn"
  cd $WSGI_PATH
  gunicorn mywebsite.wsgi > /dev/null 2>&1 &
}

stop_website() {
  echo "------------------------Stopping website------------------------------------"

  for pid in $(ps aux | grep '[g]unicorn' | awk '{print $2}')
  do
    echo "Killing gunicorn at $pid"
    kill $pid
  done

  for pid in $(ps aux | grep '[n]ginx' | awk '{print $2}')
  do
    echo "Killing nginx at $pid"
    kill $pid
  done
}

cleanup() {
  # Remove certbot
  echo "----------------------------Removing Certbot---------------------------"
  snap remove certbot
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
}
