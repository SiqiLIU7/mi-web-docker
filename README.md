# mi-web-docker
Docker installation for mi-web website UI (integrated with OpenAirInterface eNB and MobileInsight eNB)

# Usage
## Install 
Note: Only support Ubuntu. Will support more OS in the future.
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
1. build docker containers for our project (app container, nginx container, mysql container)
2. In app container:
   1. install mi-web (https://github.com/ZhaoweiTan/mi-web.git) 
   2. install MobileInsight_enb (https://github.com/ZhaoweiTan/mobile_insight_enb.git)  
   3. install OpenAirInterface_enb (https://github.com/ZhaoweiTan/MI-eNB.git) and build it 

The entire installation may take around 30 minutes to finish.

## Run
Open browser, and enter http://localhost:8080/ to start exploring!

# Debug
If Laravel or php related errors occur on website, please first try the following commands in your host to fix:
```
docker exec -it app php artisan config:clear
docker exec -it app php artisan cache:clear
docker exec -it app php artisan route:clear
docker exec -it app php artisan view:clear
docker exec -it app php artisan key:generate
docker exec -it app php artisan config:cache
docker exec -it app php artisan migrate
```
