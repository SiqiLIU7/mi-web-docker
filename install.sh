#!/bin/sh
CURRENT_PATH="$(pwd)"

yes | ./uninstall.sh

# ======Install docker ====== 
echo "\n### Begin installing Docker of the latest version ###\n"
echo "\nUninstall previously installed Docker"
sudo apt-get remove docker docker-engine docker.io containerd runc

echo "\nInstall Docker (version: 5:18.09.9~3-0~ubuntu-xenial)"
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
DOCKER_VERSION="$(apt-cache madison docker-ce | head -1 |  awk '{print $3;}')"
sudo apt-get install docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io
sudo apt install docker-compose
echo "### Docker installed successfully! ###\n"


# ======Install mi-web ====== 
echo "\n### Begin installing mi-web ###"

MI_WEB_REPO_URL="https://github.com/ZhaoweiTan/mi-web.git"
OAI_REPO_URL="https://github.com/ZhaoweiTan/MI-eNB.git"
MI_ENB_REPO_URL="https://github.com/ZhaoweiTan/mobile_insight_enb.git"

WORKING_DIR="$HOME/mi_web_workdir"
APP_DIRNAME="mi-web"

echo "Remove previous installed working directory..."
sudo rm -r $WORKING_DIR

# Initial Setup
echo "\nDownloading mi-web repo ..."
mkdir $WORKING_DIR
git clone $MI_WEB_REPO_URL $WORKING_DIR/$APP_DIRNAME

echo "\nInstalling configuration files..."
# echo "Installing PHP configurations"
mkdir -p $WORKING_DIR/$APP_DIRNAME/php
cp ./php/local.ini $WORKING_DIR/$APP_DIRNAME/php/
# echo "Installing Nginx Configurations"
mkdir -p $WORKING_DIR/$APP_DIRNAME/nginx/conf.d
cp ./nginx/conf.d/app.conf $WORKING_DIR/$APP_DIRNAME/nginx/conf.d/
# echo "Installing MySQL Configurations"
mkdir -p $WORKING_DIR/$APP_DIRNAME/mysql
cp ./mysql/my.cnf $WORKING_DIR/$APP_DIRNAME/mysql
sed "s/DB_PASSWORD=/DB_PASSWORD=123456/g;s/DB_HOST=127.0.0.1/DB_HOST=db/g;" $WORKING_DIR/$APP_DIRNAME/.env.example > $WORKING_DIR/$APP_DIRNAME/.env

echo "\nLAUNCH mi-web ... "
cp ./docker-compose.yml $WORKING_DIR/$APP_DIRNAME
cp ./Dockerfile $WORKING_DIR/$APP_DIRNAME

docker run --rm -v $WORKING_DIR/$APP_DIRNAME:/app composer update laravel/framework
docker run --rm -v $WORKING_DIR/$APP_DIRNAME:/app composer install

sudo chown -R $USER:$USER $WORKING_DIR/$APP_DIRNAME

cd $WORKING_DIR/$APP_DIRNAME

docker-compose down && docker-compose up --build -d

docker exec -it --user www-data app php artisan config:clear
docker exec -it --user www-data app php artisan cache:clear
docker exec -it --user www-data app php artisan route:clear
docker exec -it --user www-data app php artisan view:clear

docker exec -it app php artisan key:generate
docker exec -it app php artisan config:cache
docker exec -it --user www-data app php artisan migrate

echo "\nDownloading MobileInsight_enb ..."
docker exec -it --user www-data app git clone $MI_ENB_REPO_URL public/mi/mobile_insight_enb

# docker exec -it --user www-data app sudo apt-get update
# docker exec -it --user www-data app sudo apt-get install -y libgcrypt20-dev libglib2.0-dev flex bison

echo "\nCompiling MobileInsight_enb ..."
docker exec -it app bash -c "cd public/mi/mobile_insight_enb && ./install-ubuntu.sh"

echo "\nDownloading OpenAirInterface ..."
docker exec -it --user www-data app git clone $OAI_REPO_URL public/mi/MI-eNB

echo "\nBuilding OpenAirInterface ... it may take a long time"
docker exec -it --user www-data app sudo ./public/mi/MI-eNB/cmake_targets/build_oai -I -w USRP --eNB --UE # build as non-root user
docker exec -it --user www-data app python3 -m pip install matplotlib
echo "Finish building OpenAirInterface!"

cd $WORKING_DIR/$APP_DIRNAME

