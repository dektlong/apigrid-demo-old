#!/usr/bin/env bash

source secrets/config-values.env

pushd $BOOT_OBSERVER_INSTALL_DIR

	#create git secret to access SBO's private repo
    #export GIT_PASSWORD=${PASSWORD}
    #kp secret create dekt-private-git-secret --git-url $sbo_repo --git-user dektlong -n $sbo_namesapce


#git pull

#mvn -DskipTests clean install
    
#sbo-server
cd spring-boot-observer-server
mvn -DskipTests spring-boot:build-image
docker tag spring-boot-observer-server:0.0.1-SNAPSHOT $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/spring-boot-observer-server:0.0.1
docker push $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/spring-boot-observer-server:0.0.1

           
    ## build image for spring-boot-observer-server
    #kp image create spring-boot-observer-server \
	#--tag $REGISTRY/$SYSTEM_REPO/spring-boot-observer-server:0.0.1 \
	#--git $sbo_repo \
	#--git-revision main \
	#--sub-path ./spring-boot-observer-server \
	#--namespace $sbo_namesapce \
	#--wait
    
## sbo-sidecar
cd ../spring-boot-observer-sidecar
mvn -DskipTests spring-boot:build-image
docker tag spring-boot-observer-sidecar:0.0.1-SNAPSHOT $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/spring-boot-observer-sidecar:0.0.1
docker push $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/spring-boot-observer-sidecar:0.0.1

    ## build image for spring-boot-observer-sidecar
    #kp image create spring-boot-observer-sidecar\
	#--tag $REGISTRY/$APP_REPO/spring-boot-observer-sidecar:0.0.1 \
	#--git $sbo_repo \
	#--git-revision main \
	#--sub-path ./spring-boot-observer-sidecar \
	#--namespace $sbo_namesapce \
	#--wait

#fortune-service sample app
cd ../samples/fortune-teller/fortune-service
mvn -DskipTests spring-boot:build-image
docker tag fortune-service:0.0.1-SNAPSHOT $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/fortune-service:0.0.1
docker push $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/fortune-service:0.0.1

pushd