#!/usr/bin/env bash

#################### configs #######################

    source secrets/config-values.env
    
    DET4PETS_FRONTEND_IMAGE_LOCATION=$PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/$FRONTEND_TBS_IMAGE:$APP_VERSION
    DET4PETS_BACKEND_IMAGE_LOCATION=$PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION
    TAP_INSTALL_NAMESPACE="tap-install"
    GW_NAMESPACE="scgw-system"
    API_PORTAL_NAMESPACE="api-portal-system"
    BROWNFIELD_NAMESPACE="brownfield-apis"

#################### core functions ################

    #install all demo components
    install-all () {

        platform/scripts/install-nginx.sh
        
        create-namespaces-secrets

        update-config-values

        install-tap

        install-gateway

        install-api-portal
        
        setup-demo-examples

        echo
        echo "Demo install completed. Enjoy your demo."
        echo
    }

    #install-tap
    install-tap() {

        #tap package
        echo
        echo "===> Installing Tanzu Application Platform packages..."
        echo

        kapp deploy -y -a kc -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
        kapp deploy -a tap-package-repo -n $TAP_INSTALL_NAMESPACE -f platform/tap/tap-package-repo.yaml -y

        wait-for-reconciler

        tanzu package available list -n $TAP_INSTALL_NAMESPACE
        echo

        #acc package
        echo
        echo "===> Install Application Accelerator TAP package..."
        echo
        kapp deploy -y -a flux -f https://github.com/fluxcd/flux2/releases/download/v0.15.0/install.yaml
        tanzu package install app-accelerator -p accelerator.apps.tanzu.vmware.com -v 0.2.0 -n $TAP_INSTALL_NAMESPACE -f secrets/tap/acc-values.yaml
        kubectl apply -f platform/acc/config/acc-ingress.yaml -n accelerator-system #ns need to match secrets/tap/acc-values.yaml watched_namespace

        #cnr package
        echo
        echo "===> Install Cloud Native Runtime TAP package..."
        echo
        tanzu package install cloud-native-runtimes -p cnrs.tanzu.vmware.com -v 1.0.1 -n tap-install -f platform/cnr/config/cnr-values.yaml
        platform/scripts/update-dns.sh "envoy" "contour-external" "*.cnr"

        #install alv
        echo
        echo "===> Install Application Live View TAP package..."
        echo
        #tanzu package install app-live-view -p appliveview.tanzu.vmware.com -v 0.1.0 -n tap-install -f platform/alv/config/alv-values.yaml
        #kubectl apply -f platform/alv/config/alv-ingress.yaml -n app-live-view #ns need to match secrets/tap/alv-values.yaml server_namespace
        
        #need to wait until seperate ns for the controller is supported in TAP, until then has to be installed seperatly 
        install-alv 
        
        echo
        echo "===> Installing Tanzu Build Service..."
        echo
        #not supported yet as a TAP pacakge    install-tbs #not supported yet as a TAP pacakge
        install-tbs 


    }
    
    #install-gateway
    install-gateway() {
        
        echo
        echo "===> Installing Spring Cloud Gateway operator..."
        echo
    
        #install-SGGW-from-source 
        
        $GW_INSTALL_DIR/scripts/install-spring-cloud-gateway.sh --namespace $GW_NAMESPACE
    }

    #install tanzu app accelerator (deprecated when using TAP)
    install-acc() {

        acc_ns="accelerator-system"

        kubectl create ns $acc_ns

        kapp deploy -y -a flux -f https://github.com/fluxcd/flux2/releases/download/v0.15.0/install.yaml

        #until k8s secret is supported
        export acc_registry__server=registry.pivotal.io
        export acc_registry__username=$TANZU_NETWORK_USER
        export acc_registry__password=$TANZU_NETWORK_PASSWORD
        
        #we use ingress rule
        export acc_server_service_type=ClusterIP

        ytt -f /tmp/acc-install-bundle/config -f /tmp/acc-install-bundle/values.yml --data-values-env acc  \
            | kbld -f /tmp/acc-install-bundle/.imgpkg/images.yml -f- \
            | kapp deploy -y -n $acc_ns -a accelerator -f-

        kubectl apply -f platform/acc/config/acc-ingress.yaml -n $acc_ns

    }

    #install TBS
    install-tbs() {
        
        ytt -f $TBS_INSTALL_DIR/values.yaml \
            -f $TBS_INSTALL_DIR/manifests/ \
            -v docker_repository="$PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO/build-service" \
            -v docker_username="$PRIVATE_REGISTRY_USER" \
            -v docker_password="$PRIVATE_REGISTRY_PASSWORD" \
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

    #install-alv (deprecated when using TAP)
    install-alv () {

        alv_ns="app-live-view"

        kubeclt create ns $alv_ns

        #enable ALV server and ALV connector to access taznu net for install
        kubectl create secret \
            docker-registry alv-secret-values -n $alv_ns\
            --docker-server=dev.registry.pivotal.io \
            --docker-username=$TANZU_NETWORK_USER \
            --docker-password=$TANZU_NETWORK_PASSWORD

        ytt -f /tmp/application-live-view-install-bundle/config -f secrets/tap/alv-values.yaml \
            | kbld -f /tmp/application-live-view-install-bundle/.imgpkg/images.yml -f- \
            | kapp deploy -y -n $alv_ns-a application-live-view -f-

        kubectl apply -f platform/alv/config/alv-ingress.yaml -n $alv_ns
    }

    #install-cnr (deprecated when using TAP)
    install-cnr() {

        
        cnr_install_dir="/Users/dekt-code/code/servercloud-native-runtimes"

        kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml


        export cnr_registry__server=$PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO/cnr
        export cnr_registry__username=$PRIVATE_REGISTRY_USER
        export cnr_registry__password=$PRIVATE_REGISTRY_PASSWORD
        
        $CNR_INSTALL_DIR/bin/install.sh -y

        platform/scripts/update-dns.sh "envoy" "contour-external" "*.cnr"
            
        kubectl apply -f platform/cnr/cnr-domain-conifg.yaml
    }

    #setup-demo-examples
    setup-demo-examples() {

        echo
        echo "===> Setup App Accelerator examples..."
        echo
        kubectl apply -f platform/acc/add-accelerators.yaml -n $ACC_NAMESPACE

        echo
        echo "===> Setup brownfield APIs examples..."
        echo
        kustomize build platform/api-portal | kubectl apply -f -

        echo
        echo "===> Start dekt4pets micro-gateway with public access..."
        echo
        kustomize build platform/gateway | kubectl apply -f -


        kubectl apply -f platform/alv/pet-clinic-alv.yaml -n $APP_NAMESPACE

        create-dekt4pets-images
        
        create-adopter-check-image
    }

    #update-core-images
    update-core-images () {

        echo "Make sure the docker desktop deamon is running. Press any key to continue..."
        read
        docker login -u $PRIVATE_REGISTRY_USER -p $PRIVATE_REGISTRY_PASSWORD $PRIVATE_REGISTRY_URL
        
        case $1 in
        gateway)
            $GW_INSTALL_DIR/scripts/relocate-images.sh $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO
            ;;
        acc)
            imgpkg pull -b $ACC_INSTALL_BUNDLE -o /tmp/acc-install-bundle
            ;;
        tbs)
            kbld relocate -f $TBS_INSTALL_DIR/images.lock --lock-output $TBS_INSTALL_DIR/images-relocated.lock --repository $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO/build-service
            
            ;;
        api-portal)
            $API_PORTAL_INSTALL_DIR/scripts/relocate-images.sh $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO
            ;;
        alv)
            imgpkg pull -b dev.registry.pivotal.io/app-live-view/application-live-view-install-bundle:0.1.1 \
                -o /tmp/application-live-view-install-bundle
            ;;
        cnr)
            imgpkg copy --lock $CNR_INSTALL_DIR/cloud-native-runtimes-1.0.1.lock --to-repo $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO/cnr --lock-output $CNR_INSTALL_DIR/relocated.lock --registry-verify-certs=false 
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

    #create dekt4pets images
    create-dekt4pets-images () {

        echo
        echo "===> Create dekt4pets builder..."
        echo
        kp builder save $BUILDER_NAME -n $APP_NAMESPACE \
        --tag $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/$BUILDER_NAME \
        --order platform/tbs/dekt-builder-order.yaml \
        --stack full \
        --store default
    
        echo
        echo "===> Create dekt4pets-backend TBS image..."
        echo        
        kp image save $BACKEND_TBS_IMAGE -n $APP_NAMESPACE \
        --tag $DET4PETS_BACKEND_IMAGE_LOCATION \
        --git $DEMO_APP_GIT_REPO  \
        --sub-path ./workloads/dekt4pets/backend \
        --git-revision main \
        --wait
        
        echo
        echo "===> Create dekt4pets-frontend TBS image..."
        echo        
        kp image save $FRONTEND_TBS_IMAGE -n $APP_NAMESPACE \
        --tag $DET4PETS_FRONTEND_IMAGE_LOCATION \
        --git $DEMO_APP_GIT_REPO  \
        --sub-path ./workloads/dekt4pets/frontend \
        --git-revision main \
        --wait


    }
    
    #create adopter-check image
    create-adopter-check-image () {

        echo
        echo "===> Create adopter-check TBS image..."
        echo 

        kp image save adopter-check -n $APP_NAMESPACE \
            --tag $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/adopter-check:0.0.1 \
            --git $DEMO_APP_GIT_REPO  \
            --sub-path ./workloads/dekt4pets/adopter-check \
            --cluster-builder tiny \
            --env BP_BOOT_NATIVE_IMAGE=1 \
            --env BP_JVM_VERSION=11 \
            --env BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true package spring-boot:repackage" \
            --env BP_BOOT_NATIVE_IMAGE_BUILD_ARGUMENTS="-Dspring.spel.ignore=true -Dspring.xml.ignore=true -Dspring.native.remove-yaml-support=true --enable-all-security-services" \
            --wait 
    }
    #create-namespaces-secrets
    create-namespaces-secrets () {

        echo
        echo "===> Creating namespaces and secrets..."
        echo
        
        #namespaces
        kubectl create ns $TAP_INSTALL_NAMESPACE
        kubectl create ns $APP_NAMESPACE
        kubectl create ns $GW_NAMESPACE
        kubectl create ns $API_PORTAL_NAMESPACE
        kubectl create ns $BROWNFIELD_NAMESPACE
        
        #tap install ns
        kubectl create secret docker-registry tap-registry \
            -n $TAP_INSTALL_NAMESPACE \
            --docker-server=$TANZU_NETWORK_REGISTRY \
            --docker-username=$TANZU_NETWORK_USER \
            --docker-password=$TANZU_NETWORK_PASSWORD     

  
        #enable deployments in APP_NS to access private image registry 
        #need to be created with tbs cli and not kubectl to register the secret in TBS
        #can be reused by all other app deployments
        
        export REGISTRY_PASSWORD=$PRIVATE_REGISTRY_PASSWORD
        kp secret create imagereg-secret \
            --registry $PRIVATE_REGISTRY_URL \
            --registry-user $PRIVATE_REGISTRY_USER \
            --namespace $APP_NAMESPACE 
        
        #enable SCGW to access image registry (has to be that specific name)
        kubectl create secret docker-registry spring-cloud-gateway-image-pull-secret \
            --docker-server=$PRIVATE_REGISTRY_URL \
            --docker-username=$PRIVATE_REGISTRY_USER \
            --docker-password=$PRIVATE_REGISTRY_PASSWORD \
            --namespace $GW_NAMESPACE
        
        #enable API-portal to access image registry (has to be that specific name)
        kubectl create secret docker-registry api-portal-image-pull-secret \
            --docker-server=$PRIVATE_REGISTRY_URL \
            --docker-username=$PRIVATE_REGISTRY_USER \
            --docker-password=$PRIVATE_REGISTRY_PASSWORD \
            --namespace $API_PORTAL_NAMESPACE
      
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

        #gateway
        platform/scripts/replace-tokens.sh "platform/gateway" "dekt4pets-gateway.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/gateway" "dekt4pets-ingress.yaml" "{HOST_NAME}" "$hostName"
        #acc
        platform/scripts/replace-tokens.sh "platform/acc" "acc-ingress.yaml" "{HOST_NAME}" "$hostName"
               #api-portal
        platform/scripts/replace-tokens.sh "platform/api-portal" "scg-openapi-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "api-portal-ingress.yaml" "{HOST_NAME}" "$hostName"
        #alv
        platform/scripts/replace-tokens.sh "platform/alv" "alv-ingress.yaml" "{HOST_NAME}" "$hostName"
        #brownfeild-apis
        platform/scripts/replace-tokens.sh "platform/api-portal" "datacheck-brownfield-api.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "suppliers-brownfield-api.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "donations-brownfield-api.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "datacheck-ingress.yaml" "{HOST_NAME}" "$hostName"
        #dekt4pets
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/backend" "dekt4pets-backend-app.yaml" "{BACKEND_IMAGE}" "$DET4PETS_BACKEND_IMAGE_LOCATION" "{OBSERVER_SIDECAR_IMAGE}" "$ALV_SIDECAR_IMAGE_LOCATION"
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/frontend" "dekt4pets-frontend-app.yaml" "{FRONTEND_IMAGE}" "springcloudservices/animal-rescue-frontend" 
            #platform/scripts/replace-tokens.sh "workloads/dekt4pets/frontend" "dekt4pets-frontend-app.yaml" "{FRONTEND_IMAGE}" "$DET4PETS_FRONTEND_IMAGE_LOCATION" 
    
    }
    #install SCGW from source code
    install-SGGW-from-source() {

        #git pull

        #TARGET_REGISTRY_NAMESPACE=registry.pivotal.io/spring-cloud-gateway-for-kubernetes ./gradlew bootBuildImage

        #./gradlew distTar

        #tar -xvf build/distributions/spring-cloud-gateway-k8s-0.0.0-$USER.tgz -C build/distributions


        #../spring-cloud-gateway-k8s/build/distributions/spring-cloud-gateway-k8s-0.0.0-$USER/scripts/relocate-images.sh $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO

        ../spring-cloud-gateway-k8s/build/distributions/spring-cloud-gateway-k8s-0.0.0-$USER/scripts/install-spring-cloud-gateway.sh \
         --namespace scgw-system \
         --operator_image $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO/scg-operator:0.0.0-dekt \
         --gateway_image $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO/gateway:0.0.0-dekt \
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
        kapp delete -n -a accelerator -y
        kustomize build legacy-apis | kubectl delete -f -
        helm uninstall spring-cloud-gateway -n $GW_NAMESPACE
        kapp delete -a tanzu-build-service -y
        kapp delete -a application-live-view -y
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
        echo "  alv"
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

    wait-for-reconciler () {
        #wait for Reconcile to complete 
        status=""
        printf "Waiting for tanzu package repository list to reconcile ."
        while [ "$status" == "" ]
        do
            printf "."
            status="$(tanzu package repository list -n $TAP_INSTALL_NAMESPACE  -o=json | grep 'succeeded')" 
            sleep 1
        done
        echo
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