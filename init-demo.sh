#!/usr/bin/env bash

#################### functions #######################

#install
install() {

    create-namespaces

    create-secrets

    setup-dynamic-values
    
    install-core-services
    
    start-local-utilities

    setup-demo-artifacts

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
}

#setup-dynamic-values
setup-dynamic-values () {

    echo
    echo "===> Copy and update ingress and depolyment yaml files with domain and image info..."
    echo

    BACKEND_IMAGE_NAME=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION
    FRONTEND_IMAGE_NAME=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$FRONTEND_TBS_IMAGE:$APP_VERSION
    HOST_URI=$SUB_DOMAIN.$DOMAIN
    
    change_token="{REPLACED_IN_RUNTIME}"
    
    mkdir {backend/.config,frontend/.config,gateway/.config,hub/.config,sbo/.config,tss/.config}

    cp backend/dekt4pets-backend-app.yaml backend/.config/dekt4pets-backend-app.yaml
    perl -pi -w -e "s|$change_token|$BACKEND_IMAGE_NAME|g;" backend/.config/dekt4pets-backend-app.yaml

    cp frontend/dekt4pets-frontend-app.yaml frontend/.config/dekt4pets-frontend-app.yaml
    perl -pi -w -e "s|$change_token|$FRONTEND_IMAGE_NAME|g;" frontend/.config/dekt4pets-frontend-app.yaml

    cp gateway/dekt4pets-gateway.yaml gateway/.config/dekt4pets-gateway.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" gateway/.config/dekt4pets-gateway.yaml

    cp gateway/dekt4pets-ingress.yaml gateway/.config/dekt4pets-ingress.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" gateway/.config/dekt4pets-ingress.yaml

    cp hub/brownfield-apis/datacheck-gateway.yaml hub/.config/datacheck-gateway.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" hub/.config/datacheck-gateway.yaml

    cp hub/brownfield-apis/donations-gateway.yaml hub/.config/donations-gateway.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" hub/.config/donations-gateway.yaml

    cp hub/brownfield-apis/suppliers-gateway.yaml hub/.config/suppliers-gateway.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" hub/.config/suppliers-gateway.yaml

    cp hub/scg-openapi-ingress.yaml hub/.config/scg-openapi-ingress.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" hub/.config/scg-openapi-ingress.yaml

    cp hub/run-local-api-hub-server.sh hub/.config/run-local-api-hub-server.sh
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" hub/.config/run-local-api-hub-server.sh
    perl -pi -w -e "s|{RUNTIME_PATH_TO_API_HUB_JAR}|$RUNTIME_PATH_TO_API_HUB_JAR|g;" hub/.config/run-local-api-hub-server.sh

    cp sbo/fortune-ingress.yaml sbo/.config/fortune-ingress.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" sbo/.config/fortune-ingress.yaml

    cp sbo/sbo-ingress.yaml sbo/.config/sbo-ingress.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" sbo/.config/sbo-ingress.yaml

    cp tss/tss-ingress.yaml tss/.config/tss-ingress.yaml
    perl -pi -w -e "s|$change_token|$HOST_URI|g;" tss/.config/tss-ingress.yaml

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
    kubectl create secret docker-registry imagereg-secret -n \
        --docker-server=$IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO \
        --docker-username=$IMG_REGISTRY_USER \
        --docker-password=$IMG_REGISTRY_PASSWORD \
        --namespace $SBO_NAMESPACE 
   
    #sso secret for dekt4pets-gatway 
    kubectl create secret generic dekt4pets-sso --from-env-file=myconfigs/dekt4pets-sso.txt -n $APP_NAMESPACE

    #jwt secret for dekt4pets backend app
    kubectl create secret generic dekt4pets-jwk --from-env-file=myconfigs/dekt4pets-jwk.txt -n $APP_NAMESPACE
    

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
}

#install starter service
install-tss() {

    echo
    echo "===> Install Tanzu Starter Service..."
    echo
    
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
    kubectl apply -f hub/.config/scg-openapi-ingress.yaml -n $GW_NAMESPACE

    #until hub is available as a k8s deployment it will be started localy as part of start-local-utilities 
}

#install-sbo (spring boot observer)
install-sbo () {

    #you need to build and relocate the SBO images to your repo
    #sbo/build-and-relocate-images.sh   

    ## Create sbo deployment and ingress rule
    kubectl apply -f sbo/sbo-deployment.yaml -n $SBO_NAMESPACE
    kubectl apply -f sbo/.config/sbo-ingress.yaml -n $SBO_NAMESPACE 

}

#setup demo artifacts
setup-demo-artifacts() {

    echo
    echo "===> Setup demo artifact: brownfield APIs ..."
    echo
    kustomize build hub/brownfield-apis | kubectl apply -f -

    echo
    echo "===> Setup demo artifact: spring-boot-observer fortune-service..."
    echo
    kubectl apply -f sbo/fortune-sidecar-example.yaml -n $APP_NAMESPACE 

    echo
    echo "===> Setup demo artifact: tss generators and starters..."
    echo
    tss/dekt-starters/add-starters.sh
    #tss/msft-starters/add-starters.sh

    echo
    echo "===> Setup demo artifact: create dekt4pets TBS backend images..."
    echo
    #create a builder that can only run in dekt-apps ns and used to build java and nodejs apps
    #kp builder create $BUILDER_NAME \
    #--tag $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BUILDER_NAME \
    #--order tbs/dekt-builder-order.yaml \
    #--stack full \
    #--store default \
    #--namespace $APP_NAMESPACE
    
    #backend (git commits to the main branch will be auto-built by TBS)
    kp image create $BACKEND_TBS_IMAGE \
	--tag $BACKEND_IMAGE_NAME \
    --git $DEMO_APP_GIT_REPO  \
	--git-revision main \
	--sub-path ./backend \
	--namespace $APP_NAMESPACE \
	--wait
    #--builder $BUILDER_NAME \

    echo
    echo "===> Setup demo artifact  5/5 : create dekt4pets TBS frontend image..."
    echo
    
    #frontend
    #"!! since animals-frontend does *not* currently compile with TBS, 
    # as a workaround we relocate the image from springcloudservices/animal-rescue-frontend"
    docker pull springcloudservices/animal-rescue-frontend
    docker tag springcloudservices/animal-rescue-frontend:latest $FRONTEND_IMAGE_NAME
    docker push $FRONTEND_IMAGE_NAME

    #kp image create $FRONTEND_TBS_IMAGE \
	#--tag $FRONTEND_IMAGE_NAME \
	#--git $DEMO_APP_GIT_REPO\
    #--git-revision main \
   	#--sub-path ./frontend \
	#--namespace $APP_NAMESPACE \
	#--wait
}

#start local utilities
start-local-utilities() {

    #temp unitl Hub as a k8s deployment
    open -a Terminal hub/.config/run-local-api-hub-server.sh

    open -a Terminal k8s-builders/start_octant.sh
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
*)
    incorrect-usage
    ;;
esac
