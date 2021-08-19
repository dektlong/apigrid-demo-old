#!/usr/bin/env bash

#################### configs #######################

    source secrets/config-values.env
    
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


#################### core functions ################

    #install all demo components
    install-all () {

        platform/scripts/install-nginx.sh
        
        create-namespaces-secrets

        update-config-values

        install-gateway

        install-acc
        
        install-api-portal
        
        install-sbo

        install-tbs

        setup-demo-examples

        install-cnr

        echo
        echo "Demo install completed. Enjoy your demo."
        echo
    }

    #install-gateway
    install-gateway() {
        
        echo
        echo "===> Installing Spring Cloud Gateway operator..."
        echo
    
        #install-SGGW-from-source 
        
        $GW_INSTALL_DIR/scripts/install-spring-cloud-gateway.sh --namespace $GW_NAMESPACE
    }

    #install tanzu app accelerator 
    install-acc() {

        echo
        echo "===> Install Tanzu Application Accelerator..."
        echo

        kubectl apply -f https://gist.githubusercontent.com/trisberg/f53bbaa0b8aacba0ec64372a6fb6acdf/raw/44a923959945d64bad5865566e4ee6628c3cdd1f/acc-flux2.yaml

        imgpkg pull -b $ACC_INSTALL_BUNDLE -o /tmp/acc-install-bundle
        
        export acc_server_service_type=ClusterIP

        ytt -f /tmp/acc-install-bundle/config -f /tmp/acc-install-bundle/values.yml --data-values-env acc  \
            | kbld -f /tmp/acc-install-bundle/.imgpkg/images.yml -f- \
            | kapp deploy -y -n $ACC_NAMESPACE  -a accelerator -f-

        kubectl apply -f platform/acc/config/acc-ingress.yaml -n $ACC_NAMESPACE

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

        kp import -f platform/tbs/descriptor-full.yaml

    }

    #install-api-portal
    install-api-portal() {

        echo
        echo "===> Installing API portal..."
        echo

        $API_PORTAL_INSTALL_DIR/scripts/install-api-portal.sh $API_PORTAL_NAMESPACE
        
        kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS=http://scg-openapi.$SUB_DOMAIN.$DOMAIN/openapi -n $API_PORTAL_NAMESPACE

        kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS_CACHE_TTL_SEC=10 -n $API_PORTAL_NAMESPACE #so frontend apis will appear faster, just for this demo

        kubectl apply -f platform/api-portal/config/api-portal-ingress.yaml -n $API_PORTAL_NAMESPACE

        kubectl apply -f platform/api-portal/config/scg-openapi-ingress.yaml -n $GW_NAMESPACE

    
    }

    #install-sbo (spring boot observer)
    install-sbo () {

        echo
        echo "===> Installing Spring Boot Observer..."
        echo
    
        # Create sbo deployment and ingress rule
        kubectl apply -f platform/sbo/config/sbo-deployment.yaml -n $SBO_NAMESPACE
        kubectl apply -f platform/sbo/config/sbo-ingress.yaml -n $SBO_NAMESPACE 
    }

    #install-cnr (cloud native runtime)
    install-cnr() {

        echo
        echo "===> Installing Tanzu Cloud Native Runtime..."
        echo

        kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml


        export cnr_registry__server=$IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/cnr
        export cnr_registry__username=$IMG_REGISTRY_USER
        export cnr_registry__password=$IMG_REGISTRY_PASSWORD
        
        $CNR_INSTALL_DIR/bin/install.sh -y

        platform/scripts/update-dns.sh "envoy" "contour-external" "*.cnr"
            
        kubectl apply -f platform/cnr/cnr-domain-conifg.yaml
    }

    #setup-demo-examples
    setup-demo-examples() {

        echo
        echo "===> Setup SBO fortune service example..."
        echo
        kubectl apply -f platform/sbo/config/fortune-sidecar-example.yaml -n $APP_NAMESPACE 

        echo
        echo "===> Setup App Accelerator examples..."
        echo
        kubectl apply -f platform/acc/add-accelerators.yaml
        
        echo
        echo "===> Setup brownfield APIs examples..."
        echo
        kustomize build platform/api-portal | kubectl apply -f -

        echo
        echo "===> Start dekt4pets micro-gateway with public access..."
        echo
        kustomize build platform/gateway | kubectl apply -f -

        echo
        echo "===> Create dekt4pets builder..."
        echo
        kp builder create $BUILDER_NAME -n $APP_NAMESPACE \
        --tag $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BUILDER_NAME \
        --order platform/tbs/dekt-builder-order.yaml \
        --stack full \
        --store default
    
        echo
        echo "===> Create dekt4pets-backend TBS image..."
        echo        
        kp image create $BACKEND_TBS_IMAGE -n $APP_NAMESPACE \
        --tag $DET4PETS_BACKEND_IMAGE_LOCATION \
        --git $DEMO_APP_GIT_REPO  \
        --sub-path ./workloads/dekt4pets/backend \
        --git-revision main \
        --wait
        #--builder $BUILDER_NAME 
        
        echo
        echo "===> Create dekt4pets-frontend TBS image..."
        echo        
        kp image create $FRONTEND_TBS_IMAGE -n $APP_NAMESPACE \
        --tag $DET4PETS_FRONTEND_IMAGE_LOCATION \
        --git $DEMO_APP_GIT_REPO  \
        --sub-path ./workloads/dekt4pets/frontend \
        --git-revision main \
        --wait
    }

    #update-core-images
    update-core-images () {

        echo "Make sure the docker desktop deamon is running. Press any key to continue..."
        read
        docker login -u $IMG_REGISTRY_USER -p $IMG_REGISTRY_PASSWORD $IMG_REGISTRY_URL
        
        case $1 in
        gateway)
            $GW_INSTALL_DIR/scripts/relocate-images.sh $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO
            ;;
        acc)
            imgpkg pull -b $ACC_INSTALL_BUNDLE -o /tmp/acc-install-bundle
            ;;
        tbs)
            kbld relocate -f $TBS_INSTALL_DIR/images.lock --lock-output $TBS_INSTALL_DIR/images-relocated.lock --repository $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/build-service
            ;;
        api-portal)
            $API_PORTAL_INSTALL_DIR/scripts/relocate-images.sh $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO
            ;;
        sbo)
            platform/sbo/build-sbo-images.sh 
            ;;
        cnr)
            imgpkg copy --lock $CNR_INSTALL_DIR/cloud-native-runtimes-1.0.1.lock --to-repo $IMG_REGISTRY_URL/$IMG_REGISTRY_SYSTEM_REPO/cnr --lock-output $CNR_INSTALL_DIR/relocated.lock --registry-verify-certs=false 
            imgpkg pull --lock $CNR_INSTALL_DIR/relocated.lock -o $CNR_INSTALL_DIR
            ;;
        configs)
            update-configs
            ;;
        *)
            incorrect-usage
            ;;
        esac
    }

    #cleanup
    cleanup() {

        case $1 in
        aks)
            platform/scripts/stop-app.sh "Python"
            platform/scripts/build-aks-cluster.sh delete $CLUSTER_NAME 
            ;;
        tkg)
            remove-examples
            ;;
        *)
            incorrect-usage
            ;;
        esac
    }

#################### helpers functions #############

    #create-namespaces-secrets
    create-namespaces-secrets () {

        echo
        echo "===> Creating namespaces and secrets..."
        echo
        
        #namespaces
        kubectl create ns $APP_NAMESPACE
        kubectl create ns $GW_NAMESPACE
        kubectl create ns $API_PORTAL_NAMESPACE
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
            --namespace $API_PORTAL_NAMESPACE
        
        #enable SBO to access image registry
        kubectl create secret docker-registry imagereg-secret \
            --docker-server=$IMG_REGISTRY_URL \
            --docker-username=$IMG_REGISTRY_USER \
            --docker-password=$IMG_REGISTRY_PASSWORD \
            --namespace=$SBO_NAMESPACE

        #enable ACC to access registry.pivotal.io

        kubectl create secret docker-registry acc-image-regcred \
            --docker-server=dev.registry.pivotal.io \
            --docker-username=$TANZU_NETWORK_USER \
            --docker-password=$TANZU_NETWORK_PASSWORD \
            --namespace=$ACC_NAMESPACE 
        
        #sso secret for dekt4pets-gatway 
        kubectl create secret generic dekt4pets-sso --from-env-file=secrets/dekt4pets-sso.txt -n $APP_NAMESPACE

        #jwt secret for dekt4pets backend app
        kubectl create secret generic dekt4pets-jwk --from-env-file=secrets/dekt4pets-jwk.txt -n $APP_NAMESPACE

        #wavefront secret for dekt4pets apps
        kubectl create secret generic dekt4pets-observability --from-env-file=secrets/dekt4pets-observability-creds.txt -n $APP_NAMESPACE
    }

    #update-config-values
    update-config-values () {

        echo
        echo "===> Updating runtime configurations..."
        echo

        hostName=$SUB_DOMAIN.$DOMAIN

        platform/scripts/replace-tokens.sh "platform/gateway" "dekt4pets-gateway.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/gateway" "dekt4pets-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/acc" "acc-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "scg-openapi-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "api-portal-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/sbo" "sbo-deployment.yaml" "{OBSERVER_SERVER_IMAGE}" "$SBO_SERVER_IMAGE_LOCATION"
        platform/scripts/replace-tokens.sh "platform/sbo" "sbo-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/sbo" "fortune-sidecar-example.yaml" "{FORTUNE_IMAGE}" "$FORTUNE_IMAGE_LOCATION" "{OBSERVER_SIDECAR_IMAGE}" "$SBO_SIDECAR_IMAGE_LOCATION"
        platform/scripts/replace-tokens.sh "platform/sbo" "fortune-ingress.yaml" "{HOST_NAME}" "$SUB_DOMAIN.$DOMAIN"
        platform/scripts/replace-tokens.sh "platform/api-portal" "datacheck-brownfield-api.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "suppliers-brownfield-api.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "donations-brownfield-api.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "datacheck-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/backend" "dekt4pets-backend-app.yaml" "{BACKEND_IMAGE}" "$DET4PETS_BACKEND_IMAGE_LOCATION" "{OBSERVER_SIDECAR_IMAGE}" "$SBO_SIDECAR_IMAGE_LOCATION"
        #platform/scripts/replace-tokens.sh "workloads/dekt4pets/frontend" "dekt4pets-frontend-app.yaml" "{FRONTEND_IMAGE}" "$DET4PETS_FRONTEND_IMAGE_LOCATION" 
        #workaround for TBS issue
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/frontend" "dekt4pets-frontend-app.yaml" "{FRONTEND_IMAGE}" "springcloudservices/animal-rescue-frontend" 
    
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
    #remove examples
    remove-examples() {

        echo
        echo "===> Removing demo examples..."
        echo
        
        kustomize build workloads/dekt4pest/backend | kubectl delete -f -
        kustomize build workloads/dekt4pest/frontend | kubectl delete -f -
        kubectl delete -f platform//gateway/config/dekt4pets-ingress.yaml -n $APP_NAMESPACE
        kustomize build platform/gateway | kubectl delete -f -
        #kustomize build acc | kubectl delete -f -
        kapp delete -n $ACC_NAMESPACE -a accelerator -y
        kustomize build legacy-apis | kubectl delete -f -
        helm uninstall spring-cloud-gateway -n $GW_NAMESPACE
        kapp deploy -a tanzu-build-service -y
        kubectl delete -f platform/sbo/config/sbo-deployment.yaml -n $SBO_NAMESPACE
        kubectl delete -f platform/sbo/config/sbo-ingress.yaml -n $SBO_NAMESPACE 
        kubectl delete ns dekt-apps
        kubectl delete ns acc-system
        kubectl delete ns scgw-system 
        kubectl delete ns sbo-system 
        platform/scripts/stop-app.sh "Python"

        
    }

    #incorrect usage
    incorrect-usage() {

        bold=$(tput bold)
        normal=$(tput sgr0)
        
        echo
        echo "Incorrect usage. Please specify one of the following commands"
        echo
        echo "${bold}init-aks${normal}"
        echo "  blank"
        echo "  apigrid"
        echo "  cnr"
        echo
        echo "${bold}init-tkg${normal}"
        echo "  blank"
        echo "  apigrid"
        echo
        echo "${bold}update-core-images${normal}"
        echo "  gateway"
        echo "  acc"
        echo "  tbs"
        echo "  api-portal"
        echo "  sbo"
        echo "  cnr"
        echo "  examples"
        echo "  configs"
        echo
        echo "${bold}cleanup${normal}"
        echo "  aks"
        echo "  tkg"
        echo
        exit   
    
    }

    create-frontend-image () {
        docker pull springcloudservices/animal-rescue-frontend
        docker tag springcloudservices/animal-rescue-frontend:latest $DET4PETS_FRONTEND_IMAGE_LOCATION
        docker push $DET4PETS_FRONTEND_IMAGE_LOCATION
    }

    create-adopter-check-image () {

        kp image save adopter-check-image -n $APP_NAMESPACE \
            --tag $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/adopter-check:0.0.1 \
            --git $DEMO_APP_GIT_REPO  \
            --sub-path ./workloads/dekt4pets/adopter-check \
            --cluster-builder tiny \
            --env BP_BOOT_NATIVE_IMAGE=1 \
            --env BP_JVM_VERSION=11 \
            --env BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true package spring-boot:repackage" \
            --env BP_BOOT_NATIVE_IMAGE_BUILD_ARGUMENTS="-Dspring.spel.ignore=true -Dspring.xml.ignore=true -Dspring.native.remove-yaml-support=true --enable-all-security-services" \
            --wait 
    }

#################### main ##########################

case $1 in
init-aks)
    platform/scripts/build-aks-cluster.sh create $CLUSTER_NAME
    install-all 
    ;;
init-tkg)
    platform/scripts/build-tkg-cluster.sh tkg-i $CLUSTER_NAME_APIGRID $TKGI_CLUSTER_PLAN 1 10
    install-all 
    ;;
update-core-images)
    update-core-images $2   
    ;;
cleanup)
	cleanup $2
    ;;
runme)
    $2
    ;;
*)
    incorrect-usage
    ;;
esac