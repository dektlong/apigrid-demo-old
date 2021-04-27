#!/usr/bin/env bash

#################### configs #######################
    source supply-chain/secrets/config-values.env

    HOST_NAME=$SUB_DOMAIN.$DOMAIN
    DET4PETS_FRONTEND_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$FRONTEND_TBS_IMAGE:$APP_VERSION
    DET4PETS_BACKEND_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION
    FORTUNE_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/fortune-service:0.0.1
    SBO_SERVER_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/spring-boot-observer-server:0.0.1
    SBO_SIDECAR_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/spring-boot-observer-sidecar:0.0.1
    GW_NAMESPACE="scgw-system"
    HUB_NAMESPACE="api-portal-system"
    ACC_NAMESPACE="acc-system"
    SBO_NAMESPACE="sbo-system"
    BROWNFIELD_NAMESPACE="brownfield-apis"
    ACC_INSTALL_BUNDLE="registry.pivotal.io/app-accelerator/acc-install-bundle:1.0.0-preview-20210322"

#################### functions #######################

#install
install() {

    install-nginx
    #install-contour
    
    create-namespaces-secrets

    update-configs

    install-gateway

    install-acc
    
    install-api-portal
    
    install-sbo

    install-tbs

    install-cnr
    
    setup-demo-examples

    echo
	echo "Demo install completed. Enjoy your demo."
	echo
}

#create-namespaces-secrets
create-namespaces-secrets () {

    echo
    echo "===> Creating namespaces and secrets..."
    echo
    
    #namespaces
    kubectl create ns $APP_NAMESPACE
    kubectl create ns $GW_NAMESPACE
    kubectl create ns $HUB_NAMESPACE
    kubectl create ns $ACC_NAMESPACE
    kubectl create ns $SBO_NAMESPACE
    kubectl create ns $BROWNFIELD_NAMESPACE

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
    
    #enable API-portal to access image registry (has to be that specific name)
    kubectl create secret docker-registry api-portal-image-pull-secret \
        --docker-server=$IMG_REGISTRY_URL \
        --docker-username=$IMG_REGISTRY_USER \
        --docker-password=$IMG_REGISTRY_PASSWORD \
        --namespace $HUB_NAMESPACE
    
    #enable SBO to access image registry
    kubectl create secret docker-registry imagereg-secret \
        --docker-server=$IMG_REGISTRY_URL \
        --docker-username=$IMG_REGISTRY_USER \
        --docker-password=$IMG_REGISTRY_PASSWORD \
        --namespace=$SBO_NAMESPACE

    #enable ACC to access registry.pivotal.io
    kubectl create secret docker-registry acc-image-regcred \
        --docker-server=registry.pivotal.io \
        --docker-username=$TANZU_NETWORK_USER \
        --docker-password=$TANZU_NETWORK_PASSWORD \
        --namespace=$ACC_NAMESPACE 
   
    #sso secret for dekt4pets-gatway 
    kubectl create secret generic dekt4pets-sso --from-env-file=supply-chain/secrets/dekt4pets-sso.txt -n $APP_NAMESPACE

    #jwt secret for dekt4pets backend app
    kubectl create secret generic dekt4pets-jwk --from-env-file=supply-chain/secrets/dekt4pets-jwk.txt -n $APP_NAMESPACE
}

#update-configs 
update-configs() {

    echo
    echo "===> Updating runtime configurations..."
    echo

    #dynamic values folders
    mkdir -p {workload-backend/config,workload-frontend/config,supply-chain/gateway/config,supply-chain/api-portal/config,supply-chain/sbo/config,supply-chain/acc/config}    
    
    update-dynamic-value "supply-chain/gateway" "dekt4pets-gateway.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/gateway" "dekt4pets-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/acc" "acc-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/api-portal" "scg-openapi-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/api-portal" "api-portal-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/sbo" "sbo-deployment.yaml" "{OBSERVER_SERVER_IMAGE}" "$SBO_SERVER_IMAGE_LOCATION"
    update-dynamic-value "supply-chain/sbo" "sbo-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/sbo" "fortune-sidecar-example.yaml" "{FORTUNE_IMAGE}" "$FORTUNE_IMAGE_LOCATION" "{OBSERVER_SIDECAR_IMAGE}" "$SBO_SIDECAR_IMAGE_LOCATION"
    update-dynamic-value "supply-chain/sbo" "fortune-ingress.yaml" "{HOST_NAME}" "$SUB_DOMAIN.$DOMAIN"
    update-dynamic-value "supply-chain/api-portal" "datacheck-gateway.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/api-portal" "suppliers-gateway.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "supply-chain/api-portal" "donations-gateway.yaml" "{HOST_NAME}" "$HOST_NAME"
    update-dynamic-value "workload-backend" "dekt4pets-backend-app.yaml" "{BACKEND_IMAGE}" "$DET4PETS_BACKEND_IMAGE_LOCATION" "{OBSERVER_SIDECAR_IMAGE}" "$SBO_SIDECAR_IMAGE_LOCATION"
    update-dynamic-value "workload-frontend" "dekt4pets-frontend-app.yaml" "{FRONTEND_IMAGE}" "$DET4PETS_FRONTEND_IMAGE_LOCATION" 


    

   
}

#install-gateway
install-gateway() {
    
    echo
    echo "===> Installing Spring Cloud Gateway operator..."
    echo
   
    $GW_INSTALL_DIR/scripts/install-spring-cloud-gateway.sh $GW_NAMESPACE

    echo
    echo "=========> Start dekt4pets micro-gateway with public access..."
    echo
    kustomize build supply-chain/gateway | kubectl apply -f -
    kubectl apply -f supply-chain/gateway/config/dekt4pets-ingress.yaml -n $APP_NAMESPACE
}

#install tanzu app accelerator 
install-acc() {

    echo
    echo "===> Install Tanzu Application Accelerator..."
    echo

    imgpkg pull -b $ACC_INSTALL_BUNDLE \
       -o /tmp/acc-bundle

    export acc_service_type=ClusterIP
    export acc_import_on_startup=false
    
    ytt -f /tmp/acc-bundle/config -f /tmp/acc-bundle/values.yaml --data-values-env acc \
        | kbld -f /tmp/acc-bundle/.imgpkg/images.yml -f- \
        | kapp deploy -y -n $ACC_NAMESPACE -a accelerator -f-

    kubectl apply -f supply-chain/acc/config/acc-ingress.yaml -n $ACC_NAMESPACE

}

#install TBS
install-tbs() {
    
    echo
    echo "===> Installing Tanzu Build Service..."
    echo
    
    ytt -f $TBS_INSTALL_DIR/values.yaml \
        -f $TBS_INSTALL_DIR/manifests/ \
        -v docker_repository="$IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/build-service" \
        -v docker_username="$IMG_REGISTRY_USER" \
        -v docker_password="$IMG_REGISTRY_PASSWORD" \
        | kbld -f $TBS_INSTALL_DIR/images-relocated.lock -f- \
        | kapp deploy -a tanzu-build-service -f- -y

    kp import -f supply-chain/tbs/tbs-store-stacks-buildpacks.yaml

}

#install-api-portal
install-api-portal() {

    echo
    echo "===> Installing API portal..."
    echo

    $API_HUB_INSTALL_DIR/scripts/install-api-portal.sh $HUB_NAMESPACE
    
    kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS=http://scg-openapi.$SUB_DOMAIN.$DOMAIN/openapi -n $HUB_NAMESPACE

    kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS_CACHE_TTL_SEC=10 -n $HUB_NAMESPACE #so frontend apis will appear faster, just for this demo

    kubectl apply -f supply-chain/api-portal/config/api-portal-ingress.yaml -n $HUB_NAMESPACE

    kubectl apply -f supply-chain/api-portal/config/scg-openapi-ingress.yaml -n $GW_NAMESPACE

   
}

#install-sbo (spring boot observer)
install-sbo () {

    echo
    echo "===> Installing Spring Boot Observer..."
    echo
 
    # Create sbo deployment and ingress rule
    kubectl apply -f supply-chain/sbo/config/sbo-deployment.yaml -n $SBO_NAMESPACE
    kubectl apply -f supply-chain/sbo/config/sbo-ingress.yaml -n $SBO_NAMESPACE 
}

#install-cnr (cloud native runtime)
install-cnr() {

    echo
    echo "===> Installing Tanzu Cloud Native Runtime..."
    echo

    export serverless_docker_server=registry.pivotal.io
    export serverless_docker_username=$TANZU_NETWORK_USER
    export serverless_docker_password=$TANZU_NETWORK_PASSWORD
    
    $SERVERLESS_INSTALL_DIR/bin/install-serverless.sh

    update-dns "envoy" "contour-external" "*.native"
        
    kubectl patch configmap/config-domain \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"*.native.$DOMAIN":""}}'
}

#setup-demo-examples
setup-demo-examples() {

    echo
    echo "===> Setup SBO fortune service example..."
    echo
    kubectl apply -f supply-chain/sbo/config/fortune-sidecar-example.yaml -n $APP_NAMESPACE 

    echo
    echo "===> Setup App Accelerator examples..."
    echo
    supply-chain/acc/add-examples.sh spring http://acc.$HOST_NAME #spring | dotnet 
    
    
    echo
    echo "===> Setup brownfield APIs expamples..."
    echo
    kustomize build supply-chain/api-portal | kubectl apply -f -

    setup-dekt4pets-examples

}

#setup-dekt4pets-examples
setup-dekt4pets-examples() {

    
    echo
    echo "===> Create a builder dekt-apps ns with java, nodejs and knative buildpacks..."
    echo
    kp builder create $BUILDER_NAME -n $APP_NAMESPACE \
    --tag $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BUILDER_NAME \
    --order supply-chain/tbs/dekt-builder-order.yaml \
    --stack full \
    --store default
  
    echo
    echo "===> Create dekt4pets-backend TBS image..."
    echo
    kp image create $BACKEND_TBS_IMAGE -n $APP_NAMESPACE \
	--tag $DET4PETS_BACKEND_IMAGE_LOCATION \
    --git $DEMO_APP_GIT_REPO  \
	--sub-path ./workload-backend \
    --git-revision main \
    --wait

    --builder $BUILDER_NAME \

    echo
    echo "===> Create dekt4pets-frontend TBS image..."
    echo
    
    #frontend
    #"!! since animals-frontend does *not* currently compile with TBS, 
    # as a workaround we relocate the image from springcloudservices/animal-rescue-frontend"
    
    docker pull springcloudservices/animal-rescue-frontend
    docker tag springcloudservices/animal-rescue-frontend:latest $DET4PETS_FRONTEND_IMAGE_LOCATION
    docker push $DET4PETS_FRONTEND_IMAGE_LOCATION

    #kp image create $FRONTEND_TBS_IMAGE -n $APP_NAMESPACE \
	#--tag $DET4PETS_FRONTEND_IMAGE_LOCATION \
	#--git $DEMO_APP_GIT_REPO\
    #--git-revision main \
   	#--sub-path ./workload-frontend \
	#--wait
 
}

#update-dynamic-value
update-dynamic-value() {

    subFolder=$1
    fileName=$2
    find=($3 $5 $7)
    replace=($4 $6 $8)
    
    cp $subFolder/$fileName $subFolder/config/$fileName

    for i in ${!find[@]}; do
        perl -pi -w -e "s|${find[$i]}|${replace[$i]}|g;" $subFolder/config/$fileName
    done
    
}

#relocate-core-images
relocate-core-images() {

    echo "Make sure the docker desktop deamon is running. Press any key to continue..."
    read

    docker login -u $IMG_REGISTRY_USER -p $IMG_REGISTRY_PASSWORD $IMG_REGISTRY_URL

    #supply-chain/sbo/build-sbo-images.sh 

    $API_HUB_INSTALL_DIR/scripts/relocate-images.sh $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO

    kbld relocate -f $TBS_INSTALL_DIR/images.lock --lock-output $TBS_INSTALL_DIR/images-relocated.lock --repository $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/build-service

    $GW_INSTALL_DIR/scripts/relocate-images.sh $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO

}

#install-nginx
install-nginx() {

    echo
    echo "=========> Install nginx ingress controller ..."
    echo

    # Add the ingress-nginx repository
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

    kubectl create ns nginx-system

    # Use Helm to deploy an NGINX ingress controller
    helm install dekt4pets ingress-nginx/ingress-nginx \
        --namespace nginx-system \
        --set controller.replicaCount=2 \
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux
    
    update-dns "dekt4pets-ingress-nginx-controller" "nginx-system" "*.$SUB_DOMAIN"

}

#install-contour
install-contour() {

    echo
    echo "=========> Install contour ingress controller ..."
    echo
    
    #we use a modified install yaml to set externalTrafficPolicy: Cluster (from the local default) due to issues on AKS
    kubectl apply -f supply-chain/k8s-builders/contour-install.yaml

    update-dns "envoy" "projectcontour" "*.$SUB_DOMAIN" 
}

#update-dns
update-dns ()
{
    ingress_service_name=$1
    ingress_namespace=$2
    record_name=$3

    echo
    echo "====> Updating your DNS ..."
    echo
    
    echo
    printf "Waiting for ingress controller to receive public IP address from loadbalancer ."

    ingress_public_ip=""

    while [ "$ingress_public_ip" == "" ]
    do
	    printf "."
	    ingress_public_ip="$(kubectl get svc $ingress_service_name --namespace $ingress_namespace -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')"
	    sleep 1
    done
    
    echo

    echo "updating this A record in GoDaddy:  $record_name.$DOMAIN --> $ingress_public_ip..."

    # Update/Create DNS A Record

    curl -s -X PUT \
        -H "Authorization: sso-key $GODADDY_API_KEY:$GODADDY_API_SECRET" "https://api.godaddy.com/v1/domains/$DOMAIN/records/A/$record_name" \
        -H "Content-Type: application/json" \
        -d "[{\"data\": \"${ingress_public_ip}\"}]"
}
#cleanup
cleanup() {

    case $1 in
    aks)
	    supply-chain/k8s-builders/build-aks-cluster.sh delete $CLUSTER_NAME
        ;;
    tkg)
	    remove-examples
	    ;;
    *)
  	    supply-chain/k8s-builders/build-aks-cluster.sh delete $CLUSTER_NAME
  	    ;;
    esac
}

#remove examples
remove-examples() {

    echo
    echo "===> Removing demo examples..."
    echo
    
    kustomize build workload-backend/dekt4pets/backend | kubectl delete -f -
    kustomize build workload-frontend/dekt4pets/frontend | kubectl delete -f -
    kubectl delete -f supply-chain//gateway/config/dekt4pets-ingress.yaml -n $APP_NAMESPACE
    kustomize build supply-chain/gateway | kubectl delete -f -
    #kustomize build acc | kubectl delete -f -
    kapp delete -n $ACC_NAMESPACE -a accelerator -y
    kustomize build legacy-apis | kubectl delete -f -
    helm uninstall spring-cloud-gateway -n $GW_NAMESPACE
    kapp deploy -a tanzu-build-service -y
    kubectl delete -f supply-chain/sbo/config/sbo-deployment.yaml -n $SBO_NAMESPACE
    kubectl delete -f supply-chain/sbo/config/sbo-ingress.yaml -n $SBO_NAMESPACE 
    kubectl delete ns dekt-apps
    kubectl delete ns acc-system
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
    echo "* relocate-core-images"
    echo "* unit-test"
    echo "* cleanup [ aks | tkg  (default: aks) ]"
	echo
  	exit   
 
}

#################### main #######################

case $1 in
aks)
    supply-chain/k8s-builders/build-aks-cluster.sh create $CLUSTER_NAME 5 #nodes
    install
    ;;
tkg)
    supply-chain/k8s-builders/build-tkg-cluster.sh tkg-i $CLUSTER_NAME $TKGI_CLUSTER_PLAN 1 4
    install
    ;;
cleanup)
	cleanup $2
    ;;
relocate-core-images)
    relocate-core-images
    ;;
unit-test)
    setup-demo-examples
    ;;
*)
    incorrect-usage
    ;;
esac