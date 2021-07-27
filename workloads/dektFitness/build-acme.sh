#!/usr/bin/env bash

#################### configs #######################

    source ../_dekt4pets-demo/supply-chain/secrets/config-values.env
    
    HOST_NAME=$SUB_DOMAIN.$DOMAIN
    DET4PETS_FRONTEND_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$FRONTEND_TBS_IMAGE:$APP_VERSION
    DET4PETS_BACKEND_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION
    FORTUNE_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/fortune-service:0.0.1
    SBO_SERVER_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/spring-boot-observer-server:0.0.1
    SBO_SIDECAR_IMAGE_LOCATION=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/spring-boot-observer-sidecar:0.0.1
    GW_NAMESPACE="scgw-system"
    API_PORTAL_NAMESPACE="api-portal-system"
    SBO_NAMESPACE="sbo-system"
    BROWNFIELD_NAMESPACE="brownfield-apis"
    ACC_INSTALL_BUNDLE="dev.registry.pivotal.io/app-accelerator/acc-install-bundle:0.1.0-snapshot"
    ACC_NAMESPACE="accelerator-system" #must be that specific name for now

#################### menu functions ################


    #install-all
    install-all () {

        install-nginx

        create-namespaces-secrets

        update-configs

        install-gateway

        install-acc
        
        install-api-portal
        
        setup-demo-examples

        echo
        echo "Demo install completed. Enjoy your demo."
        echo
    }

    #install-gateway
    install-gateway() {
        
        echo
        echo "===> Installing Spring Cloud Gateway operator..."
        echo
    
        install-SGGW-from-source 
        
        #$GW_INSTALL_DIR/scripts/install-spring-cloud-gateway.sh $GW_NAMESPACE
    }

    #install tanzu app accelerator 
    install-acc() {

        echo
        echo "===> Install Tanzu Application Accelerator (Dev and DevOps instances)..."
        echo

        kubectl apply -f https://gist.githubusercontent.com/trisberg/f53bbaa0b8aacba0ec64372a6fb6acdf/raw/44a923959945d64bad5865566e4ee6628c3cdd1f/acc-flux2.yaml

        #imgpkg pull -b $ACC_INSTALL_BUNDLE -o /tmp/acc-install-bundle

        ytt -f /tmp/acc-install-bundle/config -f /tmp/acc-install-bundle/values.yml --data-values-env acc  \
            | kbld -f /tmp/acc-install-bundle/.imgpkg/images.yml -f- \
            | kapp deploy -y -n $ACC_NAMESPACE  -a accelerator -f-

        kubectl apply -f ../_dekt4pets-demo/supply-chain/acc/config/acc-ingress.yaml -n $ACC_NAMESPACE

    }

    #install-api-portal
    install-api-portal() {

        echo
        echo "===> Installing API portal..."
        echo

        $API_PORTAL_INSTALL_DIR/scripts/install-api-portal.sh $API_PORTAL_NAMESPACE
        
        kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS=http://scg-openapi.$SUB_DOMAIN.$DOMAIN/openapi -n $API_PORTAL_NAMESPACE

        kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS_CACHE_TTL_SEC=10 -n $API_PORTAL_NAMESPACE #so frontend apis will appear faster, just for this demo

        kubectl apply -f ../_dekt4pets-demo/supply-chain/api-portal/config/api-portal-ingress.yaml -n $API_PORTAL_NAMESPACE

        kubectl apply -f ../_dekt4pets-demo/supply-chain/api-portal/config/scg-openapi-ingress.yaml -n $GW_NAMESPACE

    
    }


    #setup-demo-examples
    setup-demo-examples() {

        echo
        echo "===> Setup App Accelerator examples..."
        echo
        kubectl apply -f ../_dekt4pets-demo/supply-chain/acc/add-accelerators.yaml
        
        echo
        echo "===> Setup ACME-fitness expample..."
        echo
        pushd ../dekt-fitness-demo

        kustomize build kubernetes-manifests/ | kubectl apply -f -

    }

#################### helpers functions #############

    #create-namespaces-secrets
    create-namespaces-secrets () {

        echo
        echo "===> Creating namespaces and secrets..."
        echo
        
        #namespaces
        kubectl create ns $GW_NAMESPACE
        kubectl create ns $API_PORTAL_NAMESPACE
        kubectl create ns $ACC_NAMESPACE
        kubectl create ns $BROWNFIELD_NAMESPACE


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
            --namespace $API_PORTAL_NAMESPACE
        
        #enable ACC to access registry.pivotal.io

        kubectl create secret docker-registry acc-image-regcred \
            --docker-server=dev.registry.pivotal.io \
            --docker-username=$TANZU_NETWORK_USER \
            --docker-password=$TANZU_NETWORK_PASSWORD \
            --namespace=$ACC_NAMESPACE 

    }

    #update-configs 
    update-configs() {

        echo
        echo "===> Updating runtime configurations..."
        echo

        #dynamic values folders
        mkdir -p {workload-backend/config,workload-frontend/config,../_dekt4pets-demo/supply-chain/gateway/config,../_dekt4pets-demo/supply-chain/api-portal/config,../_dekt4pets-demo/supply-chain/sbo/config,../_dekt4pets-demo/supply-chain/acc/config}    
        
        update-dynamic-value "../_dekt4pets-demo/supply-chain/gateway" "dekt4pets-gateway.yaml" "{HOST_NAME}" "$HOST_NAME"
        update-dynamic-value "../_dekt4pets-demo/supply-chain/gateway" "dekt4pets-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
        update-dynamic-value "../_dekt4pets-demo/supply-chain/acc" "acc-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
        update-dynamic-value "../_dekt4pets-demo/supply-chain/api-portal" "scg-openapi-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
        update-dynamic-value "../_dekt4pets-demo/supply-chain/api-portal" "api-portal-ingress.yaml" "{HOST_NAME}" "$HOST_NAME"
  
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

    #install SCGW from source code
    install-SGGW-from-source() {

        #git pull

        #TARGET_REGISTRY_NAMESPACE=registry.pivotal.io/spring-cloud-gateway-for-kubernetes ./gradlew bootBuildImage

        #./gradlew distTar

        #tar -xvf build/distributions/spring-cloud-gateway-k8s-0.0.0-$USER.tgz -C build/distributions


        #../spring-cloud-gateway-k8s/build/distributions/spring-cloud-gateway-k8s-0.0.0-$USER/scripts/relocate-images.sh $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO

        ../spring-cloud-gateway-k8s/build/distributions/spring-cloud-gateway-k8s-0.0.0-$USER/scripts/install-spring-cloud-gateway.sh \
         --namespace scgw-system \
         --operator_image $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/scg-operator:0.0.0-dekt \
         --gateway_image $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/gateway:0.0.0-dekt \
         --registry_credentials_secret spring-cloud-gateway-image-pull-secret


        
    }

../_dekt4pets-demo/supply-chain/k8s-builders/build-aks-cluster.sh create $CLUSTER_NAME 5 #nodes

install-all

echo
echo "dekt-fitness app ready on http://acme.tanzu.dekt.io/"
echo "use han/vmware1! to login"