#!/usr/bin/env bash

#################### functions #######################

#install
install() {

    create-namespaces

    create-secrets

    install-core-services
    
    setup-observer-examples

    setup-starters-examples

    setup-brownfield-apis

    setup-dekt4pets-examples

    echo
	echo "Demo install completed. Enjoy your demo."
	echo
}

#install core tanzu products
install-core-services() {
    
    install-gateway

    install-tss
    
    install-tbs
    
    install-apihub
    
    install-sbo

    start-local-utilities
}

#create-namespaces
create-namespaces () {

    echo
    echo "===> Creating namespaces and secrets..."
    echo
    
    #namespaces
    kubectl create ns $APP_NAMESPACE
    kubectl create ns $GW_NAMESPACE
    kubectl create ns $TSS_NAMESPACE
    kubectl create ns $SBO_NAMESPACE
    kubectl create ns $BROWNFIELD_NAMESPACE

    #dynamic values folders
    mkdir {backend/.config,frontend/.config,gateway/.config,hub/.config,sbo/.config,tss/.config}
}

#create-secrets 
create-secrets() {

    echo
    echo "===> Creating k8s secrets..."
    echo

    #enable deployments in APP_NS to access private image registry 
    #need to be created with tbs cli and not kubectl to register the secret in TBS
    #can be reused by all other app deployments
    export REGISTRY_PASSWORD=$IMG_REGISTRY_PASSWORD
    kp secret create imagereg-secret \
        --registry $IMG_REGISTRY_URL \
        --registry-user $IMG_REGISTRY_USER \
        --namespace $APP_NAMESPACE 
 

    #enable SCGW to access image registry (has to be that specific name)
    kubectl create secret docker-registry spring-cloud-gateway-image-pull-secret \
        --docker-server=$IMG_REGISTRY_URL \
        --docker-username=$IMG_REGISTRY_USER \
        --docker-password=$IMG_REGISTRY_PASSWORD \
        --namespace $GW_NAMESPACE
    
    #enable SBO to access image registry
    kubectl create secret docker-registry imagereg-secret \
        --docker-server=$IMG_REGISTRY_URL \
        --docker-username=$IMG_REGISTRY_USER \
        --docker-password=$IMG_REGISTRY_PASSWORD \
        --namespace=$SBO_NAMESPACE 
   
    #sso secret for dekt4pets-gatway 
    kubectl create secret generic dekt4pets-sso --from-env-file=secrets/dekt4pets-sso.txt -n $APP_NAMESPACE

    #jwt secret for dekt4pets backend app
    kubectl create secret generic dekt4pets-jwk --from-env-file=secrets/dekt4pets-jwk.txt -n $APP_NAMESPACE
    

    #for local images build and/or relocated to image registry
    docker login -u $IMG_REGISTRY_USER -p $IMG_REGISTRY_PASSWORD $IMG_REGISTRY_URL


}

#install-gateway
install-gateway() {
    
    echo
    echo "===> Installing Spring Cloud Gateway operator..."
    echo

    $GW_INSTALL_DIR/scripts/relocate-images.sh $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO
    
    $GW_INSTALL_DIR/scripts/install-spring-cloud-gateway.sh $GW_NAMESPACE

    update-dynamic-value gateway dekt4pets-gateway.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN
    update-dynamic-value gateway dekt4pets-ingress.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN
  
}

#install starter service
install-tss() {

    echo
    echo "===> Install Tanzu Starter Service..."
    echo
    
    update-dynamic-value tss tss-ingress.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN
    kustomize build tss | kubectl apply -f -

}

#install TBS
install-tbs() {
    
    echo
    echo "===> Installing Tanzu Build Service..."
    echo
    
    kbld relocate -f $TBS_INSTALL_DIR/images.lock --lock-output $TBS_INSTALL_DIR/images-relocated.lock --repository $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/build-service

    ytt -f $TBS_INSTALL_DIR/values.yaml \
        -f $TBS_INSTALL_DIR/manifests/ \
        -v docker_repository="$IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/build-service" \
        -v docker_username="$IMG_REGISTRY_USER" \
        -v docker_password="$IMG_REGISTRY_PASSWORD" \
        | kbld -f $TBS_INSTALL_DIR/images-relocated.lock -f- \
        | kapp deploy -a tanzu-build-service -f- -y

    kp import -f tbs/tbs-store-stacks-buildpacks.yaml

}

#install apihub
install-apihub() {

    echo
    echo "===> Installing API Hub..."
    echo

    #pushd $API_HUB_INSTALL_DIR
    #./gradlew clean build
    #pushd
    
    update-dynamic-value hub run-local-api-hub-server.sh {OPEN_API_URLS} http://scg-openapi.$SUB_DOMAIN.$DOMAIN/openapi {RUNTIME_PATH_TO_API_HUB_JAR} $API_HUB_INSTALL_DIR/api-hub-server/build/libs/api-hub-server-0.0.1-SNAPSHOT.jar
    update-dynamic-value hub scg-openapi-ingress.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN
    
    kubectl apply -f hub/.config/scg-openapi-ingress.yaml -n $GW_NAMESPACE

    #until hub is available as a k8s deployment it will be started localy as part of start-local-utilities 
}

#install-sbo (spring boot observer)
install-sbo () {

    #sbo/build-sbo-images.sh   

    update-dynamic-value sbo sbo-deployment.yaml {OBSERVER_SERVER_IMAGE} $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/spring-boot-observer-server:0.0.1
    update-dynamic-value sbo sbo-ingress.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN

    # Create sbo deployment and ingress rule
    kubectl apply -f sbo/.config/sbo-deployment.yaml -n $SBO_NAMESPACE
    kubectl apply -f sbo/.config/sbo-ingress.yaml -n $SBO_NAMESPACE 
}

#setup-observer-examples
setup-observer-examples() {

    echo
    echo "===> Setup SBO fortune service example..."
    echo

    # add the fortune service sample app
    observer_sidecar_image_tag=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/spring-boot-observer-sidecar:0.0.1
    fortune_image_tag=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/fortune-service:0.0.1

    update-dynamic-value sbo fortune-sidecar-example.yaml {FORTUNE_IMAGE} $fortune_image_tag {OBSERVER_SIDECAR_IMAGE} $observer_sidecar_image_tag
    update-dynamic-value sbo fortune-ingress.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN

    kubectl apply -f sbo/.config/fortune-sidecar-example.yaml -n $APP_NAMESPACE 

}

#setup-starters-examples
setup-starters-examples() {

    echo
    echo "===> Setup App Accelerator generators and starters..."
    echo
    tss/dekt-starters/add-starters.sh
    #tss/msft-starters/add-starters.sh

}

#setup-brownfield-apis
setup-brownfield-apis() {

    echo
    echo "===> Setup brownfield APIs expamples..."
    echo
    update-dynamic-value hub datacheck-gateway.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN
    update-dynamic-value hub suppliers-gateway.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN
    update-dynamic-value hub donations-gateway.yaml {HOST_NAME} $SUB_DOMAIN.$DOMAIN
    kustomize build hub | kubectl apply -f -
}

#setup-dekt4pets-examples
setup-dekt4pets-examples() {

    echo
    echo "===> Setup dekt4pets TBS backend images..."
    echo
    #create a builder that can only run in dekt-apps ns and used to build java and nodejs apps
    #kp builder create $BUILDER_NAME \
    #--tag $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BUILDER_NAME \
    #--order tbs/dekt-builder-order.yaml \
    #--stack full \
    #--store default \
    #--namespace $APP_NAMESPACE
    
    backend_image_tag=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION
    observer_sidecar_image_tag=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/spring-boot-observer-sidecar:0.0.1
    

    kp image create $BACKEND_TBS_IMAGE \
	--tag $backend_image_tag \
    --git $DEMO_APP_GIT_REPO  \
	--git-revision main \
	--sub-path ./backend \
	--namespace $APP_NAMESPACE \
	--wait
    #--builder $BUILDER_NAME \

    update-dynamic-value backend dekt4pets-backend-app.yaml {BACKEND_IMAGE} $backend_image_tag {OBSERVER_SIDECAR_IMAGE} $observer_sidecar_image_tag
    

    echo
    echo "===> Setup dekt4pets TBS frontend image..."
    echo
    
    frontend_image_tag=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$FRONTEND_TBS_IMAGE:$APP_VERSION

    #frontend
    #"!! since animals-frontend does *not* currently compile with TBS, 
    # as a workaround we relocate the image from springcloudservices/animal-rescue-frontend"
    
    docker pull springcloudservices/animal-rescue-frontend
    docker tag springcloudservices/animal-rescue-frontend:latest $frontend_image_tag
    docker push $frontend_image_tag

    #kp image create $FRONTEND_TBS_IMAGE \
	#--tag $FRONTEND_IMAGE_NAME \
	#--git $DEMO_APP_GIT_REPO\
    #--git-revision main \
   	#--sub-path ./frontend \
	#--namespace $APP_NAMESPACE \
	#--wait

    update-dynamic-value frontend dekt4pets-frontend-app.yaml {FRONTEND_IMAGE} $frontend_image_tag
    
}

#start local utilities
start-local-utilities() {

    #temp unitl Hub as a k8s deployment
    open -a Terminal hub/.config/run-local-api-hub-server.sh

    open -a Terminal k8s-builders/start_octant.sh
}

#update-dynamic-value
#params: sub-folder, org-file-to-update, find-key1, replace-value1, find-key2, replace-value2
update-dynamic-value() {
    cp $1/$2 $1/.config/$2
    perl -pi -w -e "s|$3|$4|g;" $1/.config/$2

    if  [ "$5" != "" ]; then 
        perl -pi -w -e "s|$5|$6|g;" $1/.config/$2
    fi

}

#cleanup
cleanup() {

    case $1 in
    aks)
	    k8s-builders/build-aks-cluster.sh delete $CLUSTER_NAME
        ;;
    tkg)
	    remove-examples
	    ;;
    *)
  	    k8s-builders/build-aks-cluster.sh delete $CLUSTER_NAME
  	    ;;
    esac

    rm -r ~/Downloads/dekt4pets-backend
    rm ~/Downloads/dekt4pets-backend.zip
    osascript -e 'quit app "Terminal"'
}

#remove examples
remove-examples() {

    echo
    echo "===> Removing demo examples..."
    echo
    
    kustomize build dekt4pets/backend | kubectl delete -f -
    kustomize build dekt4pets/frontend | kubectl delete -f -
    kubectl delete -f dekt4pets/gateway/dekt4pets-ingress.yaml -n $APP_NAMESPACE
    kustomize build dekt4pets/gateway | kubectl delete -f -
    kustomize build tss | kubectl delete -f -
    kustomize build legacy-apis | kubectl delete -f -
    helm uninstall spring-cloud-gateway -n $GW_NAMESPACE
    kapp deploy -a tanzu-build-service -y
    kubectl delete -f sbo/sbo-deployment.yaml -n $SBO_NAMESPACE
    kubectl delete -f sbo/sbo-ingress.yaml -n $SBO_NAMESPACE 
    kubectl delete ns dekt-apps
    kubectl delete ns tss-system
    kubectl delete ns scgw-system 
    kubectl delete ns sbo-system 

    
}

#incorrect usage
incorrect-usage() {
	echo
	echo "Incorrect usage. Please specify one of the following:"
	echo
  	echo "* aks"
    echo "* tkg"
    echo "* cleanup [ aks | tkg  (default: aks) ]"
	echo
  	exit   
 
}

#################### main #######################

source secrets/config-values.env

case $1 in
aks)
    k8s-builders/build-aks-cluster.sh create $CLUSTER_NAME 5 #nodes
    install
    ;;
tkg)
    k8s-builders/build-tkg-cluster.sh tkg-i $CLUSTER_NAME $TKGI_CLUSTER_PLAN 1 4
    install
    ;;
cleanup)
	cleanup $2
    ;;
unit-test)
    #backend_image_tag=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION
    #observer_sidecar_image_tag=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/spring-boot-observer-sidecar:0.0.1
    #update-dynamic-value backend dekt4pets-backend-app.yaml {BACKEND_IMAGE} $backend_image_tag {OBSERVER_SIDECAR_IMAGE} $observer_sidecar_image_tag
    ;;
*)
    incorrect-usage
    ;;
esac