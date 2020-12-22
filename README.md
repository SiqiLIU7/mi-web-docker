# mi-web-docker
Docker installation for mi-web website UI, integrated with OpenAirInterface eNB and MobileInsight eNB

# Usage
## Install 
Note: 1. Only support Ubuntu. Will support more OS in the future.
2. Please make sure ports 8080, 8443 and 8306 in your host are not occupied by other processes before installation.
```
$ sudo groupadd docker 
$ sudo gpasswd -a $USER docker 
$ newgrp docker 
$ git clone https://github.com/SiqiLIU7/mi-web-docker.git
$ cd mi-web-docker
$ chmod +x ./install.sh
$ ./install.sh
```

The `install.sh` script will do the following things: 
1. build docker containers for our project (`app` container for running laravel application, `nginx` container, `mysql` container)
2. Install services in the `app` container:
   1. install mi-web (https://github.com/ZhaoweiTan/mi-web.git) into /var/www.
   2. install MobileInsight_enb (https://github.com/ZhaoweiTan/mobile_insight_enb.git) into /var/www/public/mi/mobile_insight_enb.
   3. install OpenAirInterface_enb (https://github.com/ZhaoweiTan/MI-eNB.git) into /var/www/public/mi/MI-eNB. Then build it 

The entire installation may take around 30 minutes to finish.

## Run
Open browser, and enter http://localhost:8080/ to start exploring!

# Debug
1. Start bash in the `app` container to do whatever debugs you want:
`docker exec -it app bash`

2. If Laravel or php related error occurs on website, please first try the following commands in your host to fix:
```
docker exec -it app php artisan config:clear
docker exec -it app php artisan cache:clear
docker exec -it app php artisan route:clear
docker exec -it app php artisan view:clear
docker exec -it app php artisan key:generate
docker exec -it app php artisan config:cache
docker exec -it app php artisan migrate
```
also hava a try by adding option `--user www-data` to the above commands.

# Note
1. Port mapping: 8080 on host -> 80 on container, 8443 on host -> 443 on container, 8306 on host -> 3306 on container. Please make sure the ports 8080, 8443 and 8306 are not occupied by other processes before installation.
