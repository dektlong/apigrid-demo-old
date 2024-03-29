#!/usr/bin/env bash

#################### configs #######################

    source secrets/config-values.env
    
    DET4PETS_FRONTEND_IMAGE_LOCATION=$PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/$FRONTEND_TBS_IMAGE:$APP_VERSION
    DET4PETS_BACKEND_IMAGE_LOCATION=$PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION
    ADOPTER_CHECK_IMAGE_LOCATION=$PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/$ADOPTER_CHECK_TBS_IMAGE:$APP_VERSION
    TAP_INSTALL_NAMESPACE="tap-install"
    GW_NAMESPACE="scgw-system"
    CARTO_NAMESPACE="cartographer-system"
    API_PORTAL_NAMESPACE="api-portal"
    BROWNFIELD_NAMESPACE="brownfield-apis"

#################### core functions ################

    #init demo env
    init-demo-env () {

        case $1 in
        blank)
            platform/scripts/build-aks-cluster.sh create $CLUSTER_NAME 3
            ;;
        all)
            platform/scripts/build-aks-cluster.sh create $CLUSTER_NAME 7
            install-all
            ;;
        acc)
            platform/scripts/build-aks-cluster.sh create $CLUSTER_NAME 3
            setup-core-cluster
            install-tap-acc-package
            setup-demo-examples
            ;;
        api)
            platform/scripts/build-aks-cluster.sh create $CLUSTER_NAME 5
            setup-core-cluster 
            install-tap-acc-package
            install-gw-operator
            install-api-portal
            setup-demo-examples
            ;;
        *)
            incorrect-usage
            ;;
        esac

        echo
        echo "Demo install completed. Enjoy your demo."
        echo

    }
    
    #install-all
    install-all () {

        install-tap-acc-package
        install-tap-cnr-package
        install-tap-alv-package
        install-tbs
        install-gw-operator
        install-api-portal
        setup-demo-examples
    }
    
    #setup-core-cluster
    setup-core-cluster () {
        
        platform/scripts/install-nginx.sh
        
        create-namespaces-secrets
        
        update-config-values

        install-carto #remove post tap beta2
        
        install-tap-package-manager

    }
    #install-tap-package-manager
    install-tap-package-manager() {

        echo
        echo "===> Installing TAP package manager..."
        echo

        kapp deploy -y -a kc -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
        kapp deploy -a tap-package-repo -n $TAP_INSTALL_NAMESPACE -f platform/tap/tap-package-repo.yaml -y

        wait-for-reconciler
    }

    #install-tap-acc-package
    install-tap-acc-package() {

        echo
        echo "===> Install Application Accelerator TAP package..."
        echo
        kapp deploy -y -a flux -f https://github.com/fluxcd/flux2/releases/download/v0.15.0/install.yaml
        tanzu package install app-accelerator -p accelerator.apps.tanzu.vmware.com -v 0.2.0 -n $TAP_INSTALL_NAMESPACE -f secrets/tap/acc-values.yaml
        kubectl apply -f platform/acc/config/acc-ingress.yaml -n accelerator-system #ns need to match secrets/tap/acc-values.yaml watched_namespace
    }

    #install-tap-cnr-package
    install-tap-cnr-package() {

        echo
        echo "===> Install Cloud Native Runtime TAP package..."
        echo
        tanzu package install cloud-native-runtimes -p cnrs.tanzu.vmware.com -v 1.0.1 -n tap-install -f secrets/tap/cnr-values.yaml
        platform/scripts/update-dns.sh "envoy" "contour-external" "*.cnr"
        kubectl apply -f platform/cnr/cnr-domain-conifg.yaml
    }

    #install-tap-alv-package 
    install-tap-alv-package() {

        echo
        echo "===> Install Application Live View TAP package..."
        echo
        tanzu package install app-live-view -p appliveview.tanzu.vmware.com -v 0.1.0 -n tap-install -f secrets/tap/alv-values.yaml
        kubectl apply -f platform/alv/config/alv-ingress.yaml -n tap-install #ns need to match secrets/tap/alv-values.yaml server_namespace

    }        
        
    #install-carto
    install-carto () {

        kapp deploy --yes -a cert-manager -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.yaml

        imgpkg copy \
            --tar secrets/tap/carto-bundle.tar \
            --to-repo $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_SYSTEM_REPO/cartographer-bundle \
            --lock-output secrets/tap/cartographer-bundle.lock.yaml
        
        imgpkg pull \
            --lock secrets/tap/cartographer-bundle.lock.yaml \
            --output secrets/tap/cartographer-bundle


        kapp deploy -y -a cartographer -f <(kbld -f secrets/tap/cartographer-bundle)

    }
    
    #install-gw-operator
    install-gw-operator() {
        
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

        $API_PORTAL_INSTALL_DIR/scripts/install-api-portal.sh
        
        kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS=http://scg-openapi.$SUB_DOMAIN.$DOMAIN/openapi -n $API_PORTAL_NAMESPACE

        kubectl set env deployment.apps/api-portal-server API_PORTAL_SOURCE_URLS_CACHE_TTL_SEC=10 -n $API_PORTAL_NAMESPACE #so frontend apis will appear faster, just for this demo

        kubectl apply -f platform/api-portal/config/api-portal-ingress.yaml -n $API_PORTAL_NAMESPACE

        kubectl apply -f platform/api-portal/config/scg-openapi-ingress.yaml -n $GW_NAMESPACE

    
    }

    #install-alv (deprecated when using TAP)
    install-alv () {

        alv_ns="app-live-view"

        kubectl create ns $alv_ns

        #enable ALV server and ALV connector to access taznu net for install
        kubectl create secret \
            docker-registry alv-secret-values -n $alv_ns\
            --docker-server=dev.registry.pivotal.io \
            --docker-username=$TANZU_NETWORK_USER \
            --docker-password=$TANZU_NETWORK_PASSWORD

        ytt -f $ALV_INSTALL_DIR/config -f $ALV_INSTALL_DIR/values.yaml \
            | kbld -f $ALV_INSTALL_DIR/.imgpkg/images.yml -f- \
            | kapp deploy -y -n $alv_ns -a application-live-view -f-

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
        echo "===> Setup APIGrid demo examples..."
        echo
        #ns need to match secrets/tap/acc-values.yaml watched_namespace
        kubectl apply -f platform/acc/dev-accelerators.yaml -n accelerator-system 
        kubectl apply -f platform/acc/devops-accelerators.yaml -n accelerator-system 

        kustomize build workloads/brownfield-apis | kubectl apply -f -

        kubectl apply -f platform/alv/pet-clinic-alv.yaml -n tap-install #temp workaround

        kustomize build workloads/dekt4pets/gateway | kubectl apply -f -

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
            imgpkg pull -b dev.registry.pivotal.io/app-live-view/application-live-view-install-bundle:0.2.0-SNAPSHOT\
                -o $ALV_INSTALL_DIR
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
            platform/scripts/build-aks-cluster.sh delete $CLUSTER_NAME 
            ;;
        esac
    }

#################### helpers functions #############

    #create dekt4pets images
    create-dekt4pets-images () {

        kp builder save $BUILDER_NAME -n $APP_NAMESPACE \
        --tag $PRIVATE_REGISTRY_URL/$PRIVATE_REGISTRY_APP_REPO/$BUILDER_NAME \
        --order platform/tbs/dekt-builder-order.yaml \
        --stack full \
        --store default
    
        kp image save $BACKEND_TBS_IMAGE -n $APP_NAMESPACE \
        --tag $DET4PETS_BACKEND_IMAGE_LOCATION \
        --git $DEMO_APP_GIT_REPO  \
        --sub-path ./workloads/dekt4pets/backend \
        --git-revision main \
        --wait
        
        kp image save $FRONTEND_TBS_IMAGE -n $APP_NAMESPACE \
        --tag $DET4PETS_FRONTEND_IMAGE_LOCATION \
        --git $DEMO_APP_GIT_REPO  \
        --sub-path ./workloads/dekt4pets/frontend \
        --git-revision main \
        --wait


    }
    
    #create adopter-check image
    create-adopter-check-image () {

        
        kp image save $ADOPTER_CHECK_TBS_IMAGE -n $APP_NAMESPACE \
            --tag $ADOPTER_CHECK_IMAGE_LOCATION \
            --git https://github.com/dektlong/adopter-check \
            --cluster-builder tiny \
            --wait #\
            #--sub-path ./workloads/dekt4pets/adopter-check/java-native \
            #--env BP_BOOT_NATIVE_IMAGE=1 \
            #--env BP_JVM_VERSION=11 \
            #--env BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true package spring-boot:repackage" \
            #--env BP_BOOT_NATIVE_IMAGE_BUILD_ARGUMENTS="-Dspring.spel.ignore=true -Dspring.xml.ignore=true -Dspring.native.remove-yaml-support=true --enable-all-security-services" \
            
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
        kubectl create ns $CARTO_NAMESPACE
        kubectl create ns $API_PORTAL_NAMESPACE
        kubectl create ns $BROWNFIELD_NAMESPACE
        kubectl create ns acme-fitness
        
        #tap secret
        kubectl create secret docker-registry tap-registry \
            -n $TAP_INSTALL_NAMESPACE \
            --docker-server=$TANZU_NETWORK_REGISTRY \
            --docker-username=$TANZU_NETWORK_USER \
            --docker-password=$TANZU_NETWORK_PASSWORD
        kubectl create secret docker-registry imagereg-secret \
            --docker-server=$PRIVATE_REGISTRY_URL \
            --docker-username=$PRIVATE_REGISTRY_USER \
            --docker-password=$PRIVATE_REGISTRY_PASSWORD \
            --namespace $TAP_INSTALL_NAMESPACE  
        kubectl create secret docker-registry private-registry-credentials \
            --docker-server=$PRIVATE_REGISTRY_URL \
            --docker-username=$PRIVATE_REGISTRY_USER \
            --docker-password=$PRIVATE_REGISTRY_PASSWORD \
            --namespace $CARTO_NAMESPACE  
  
        #apps secret        
        export REGISTRY_PASSWORD=$PRIVATE_REGISTRY_PASSWORD
        kp secret create imagereg-secret \
            --registry $PRIVATE_REGISTRY_URL \
            --registry-user $PRIVATE_REGISTRY_USER \
            --namespace $APP_NAMESPACE 
          kp secret create imagereg-secret \
            --registry $PRIVATE_REGISTRY_URL \
            --registry-user $PRIVATE_REGISTRY_USER \
            --namespace $BROWNFIELD_NAMESPACE 
        
        #scgw
        kubectl create secret docker-registry spring-cloud-gateway-image-pull-secret \
            --docker-server=$PRIVATE_REGISTRY_URL \
            --docker-username=$PRIVATE_REGISTRY_USER \
            --docker-password=$PRIVATE_REGISTRY_PASSWORD \
            --namespace $GW_NAMESPACE
        
        #api-portal
        kubectl create secret docker-registry api-portal-image-pull-secret \
            --docker-server=$PRIVATE_REGISTRY_URL \
            --docker-username=$PRIVATE_REGISTRY_USER \
            --docker-password=$PRIVATE_REGISTRY_PASSWORD \
            --namespace $API_PORTAL_NAMESPACE
      
        #sso secret for gatwway and portal
        kubectl create secret generic sso-secret --from-env-file=secrets/sso-creds.txt -n $APP_NAMESPACE
        kubectl create secret generic sso-credentials --from-env-file=secrets/sso-creds.txt -n $API_PORTAL_NAMESPACE


        #jwt secret for dekt4pets backend app
        kubectl create secret generic jwk-secret --from-env-file=secrets/jwk-creds.txt -n $APP_NAMESPACE

        #wavefront secret for dekt4pets and acme-fitness app
        kubectl create secret generic wavefront-secret --from-env-file=secrets/wavefront-creds.txt -n $APP_NAMESPACE
        kubectl create secret generic wavefront-secret --from-env-file=secrets/wavefront-creds.txt -n acme-fitness
    }

    #update-config-values
    update-config-values () {

        echo
        echo "===> Updating runtime configurations..."
        echo

        hostName=$SUB_DOMAIN.$DOMAIN

        #acc
        platform/scripts/replace-tokens.sh "platform/acc" "acc-ingress.yaml" "{HOST_NAME}" "$hostName"
        #api-portal
        platform/scripts/replace-tokens.sh "platform/api-portal" "scg-openapi-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "platform/api-portal" "api-portal-ingress.yaml" "{HOST_NAME}" "$hostName"
        #alv
        platform/scripts/replace-tokens.sh "platform/alv" "alv-ingress.yaml" "{HOST_NAME}" "$hostName"
        #dekt4pets
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/backend" "dekt4pets-backend.yaml" "{BACKEND_IMAGE}" "$DET4PETS_BACKEND_IMAGE_LOCATION"
        #platform/scripts/replace-tokens.sh "workloads/dekt4pets/frontend" "dekt4pets-frontend.yaml" "{FRONTEND_IMAGE}" "$DET4PETS_FRONTEND_IMAGE_LOCATION" 
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/frontend" "dekt4pets-frontend.yaml" "{FRONTEND_IMAGE}" "springcloudservices/animal-rescue-frontend" 
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/gateway" "dekt4pets-gateway.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/gateway" "dekt4pets-gateway-dev.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/gateway" "dekt4pets-ingress.yaml" "{HOST_NAME}" "$hostName"
        platform/scripts/replace-tokens.sh "workloads/dekt4pets/gateway" "dekt4pets-ingress-dev.yaml" "{HOST_NAME}" "$hostName"
        
    
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
        echo "${bold}init${normal}"
        echo "  blank"
        echo "  all"
        echo "  acc"
        echo "  api"
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
init)
    init-demo-env $2 
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