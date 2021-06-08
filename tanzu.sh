#!/usr/bin/env bash

#################### functions #######################

#deploy-backend 
deploy-backend() {
	
    echo
    echo "=========> Sync local code with remote git $DEMO_APP_GIT_REPO ..."
    echo
    #git-push "local-development-completed"
    #codechanges=$?

    echo
    echo "=========> Invoke image build (if needed)..."
    echo
    kp image patch $BACKEND_TBS_IMAGE -n $APP_NAMESPACE
    echo
    kp build list $BACKEND_TBS_IMAGE -n $APP_NAMESPACE
    
    echo
    echo "=========> Apply backend app, service and routes ..."
    echo    
    #kubectl set image deployment/dekt4pets-backend dekt4pets-backend=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION -n $APP_NAMESPACE
    kustomize build workload-backend | kubectl apply -f -
    
}

#deploy-frontend 
deploy-frontend() {
	
    echo
    echo "=========> Apply frontend app, service and routes ..."
    echo
	
    kustomize build workload-frontend | kubectl apply -f -

}

#patch-backend
patch-backend() {
    
    git_commit_msg="add check-adopter api"
    
    echo
    echo "=========> Commit code changes to $DEMO_APP_GIT_REPO  ..."
    echo
    git-push "$git_commit_msg"
    
    echo
    echo "=========> Auto-build $BACKEND_TBS_IMAGE image on latest git commit (commit: $_latestCommitId) ..."
    echo
    
    kp image patch $BACKEND_TBS_IMAGE --git-revision $_latestCommitId -n $APP_NAMESPACE
    
    echo
    echo "Waiting for next github polling interval ..."
    echo  
    
    sleep 10 #enough time, instead of active polling which is not recommended by the TBS team
    
    kp build list $BACKEND_TBS_IMAGE -n $APP_NAMESPACE

    #kp build status $BACKEND_TBS_IMAGE -n $APP_NAMESPACE

    echo
    echo "Starting to tail build logs ..."
    echo
    
    kp build logs $BACKEND_TBS_IMAGE -n $APP_NAMESPACE
    
    echo
    echo "=========> Apply changes to backend app, service and routes ..."
    echo
    
    #workaround for image refresh issue
    kubectl delete -f workload-backend/dekt4pets-backend-app.yaml -n $APP_NAMESPACE > /dev/null 
        
    kustomize build workload-backend | kubectl apply -f -

}

#rockme-native
rockme-native () {

    case $1 in
    create)
    	kn service create rockme-native \
            --image $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/rockme:1.0.0 \
            --env TARGET="revision 1 of rockme-native" \
            --revision-name rockme-native-v1 \
            -n $APP_NAMESPACE 
        ;;
    update)
	    kn service update rockme-native \
            --image $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/rockme:1.0.0 \
            --env TARGET="revision 2 of rockme-native" \
            --revision-name rockme-native-v2 \
            --traffic @latest=20,rockme-native-v1=80 \
            -n $APP_NAMESPACE 
	    ;;
    load)
        siege -d1  -c200 -t60S  --content-type="text/plain" 'http://rockme-native.dekt-apps.native.dekt.io POST rock-on'
        ;;
    *)
  	    echo
        echo "usage: please specify { create | update | load }"
      	exit 
  	    ;;
    esac
}

#delete-workloads
delete-workloads() {

    echo
    echo "=========> Remove frontend and backend workloads..."
    echo

    kustomize build workload-backend | kubectl delete -f -

    kustomize build workload-frontend | kubectl delete -f -    

}

#################### private functions #######################

#git-push
#   param: commit message
git-push() {

    #check if this commit will have actual code changes (for later pipeline operations)
    #git diff --exit-code --quiet
    #local_changes=$? #1 if prior to commit any code changes were made, 0 if no changes made

	git commit -a -m "$1"
	git push  
	
    _latestCommitId="$(git rev-parse HEAD)"
}

#usage
usage() {

    echo
	echo "A mockup script to illustrate upcoming Tanzu concepts. Please specify one of the following:"
	echo
    echo "${bold}workflow${normal}"
    echo "  create"
    echo "  describe"
    echo
    echo "${bold}workload${normal}"
    echo "  create"
    echo "  patch"
    echo "  delete"
    echo
  	exit   
 
}

#supply-chain
workflow() {

    case $1 in
    describe)
    	echo
	    echo "The following ${bold}workflows${normal} (aka 'supplychain') have been defined in to this cluster:"
	    echo
        echo "${bold}supplychain-microservices${normal}"
        echo "--------------------------"
        echo
        echo "  ${bold}pipelines${normal}"
        echo "      => build workload(s)"
        echo "          => deploy workload(s)"
        echo "              => apply api routes(s)"
        echo
        echo "  ${bold}workloads${normal}"
        echo "      $DEMO_APP_GIT_REPO/workload-backend"
        echo "      $DEMO_APP_GIT_REPO/workload-frontend"
        echo
        echo "  ${bold}builders${normal}"
        echo "      online-stores-builder (dekt-apps namespace)"
        echo "          tanzu-buildpacks/java"
        echo "          tanzu-buildpacks/nodejs"
        echo "          tanzu-buildpacks/java-native-image"
        echo "          paketo-buildpacks/gradle"
        echo
        echo "  ${bold}images${normal}"
        echo "      $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION"
        echo "      $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$FRONTEND_TBS_IMAGE:$APP_VERSION"
        echo
        echo "  ${bold}scanners${normal}"
        echo "      https://github.com/quay/clair"
        echo
        echo
        echo "${bold}supplychain-api-gateways${normal}"
        echo "------------------------"
        echo
        echo "  ${bold}micro-gateways${normal}"
        echo "      supply-chain/datacheck-gateway.yaml (brownfield-apis namespace)"
        echo "      supply-chain/donations-gateway.yaml (brownfield-apis namespace)"
        echo "      supply-chain/suppliers-gateway.yaml (brownfield-apis namespace)"
        echo "      supply-chain/dekt4pets-gateway.yaml (dekt-apps namespace)"
        echo "      supply-chain/gateway/dekt4pets-ingress.yaml"
        echo
        echo "  ${bold}api-routes${normal}"      
        echo "      workload-backend/routes/dekt4pets-backend-routes.yaml"
        echo "      workload-frontend/routes/dekt4pets-frontend-routes.yaml"
        echo
        ;;
    create)
	    echo
        echo "Creating a new supply chain based on accelerator workload.yaml configuration ..."
        echo
        ;;
    *)
  	    usage
  	    ;;
    esac
}

#workload
workload () {

    case $1 in
    create)
        case $2 in
        backend)
            deploy-backend
            ;;
        frontend)
            deploy-frontend 
            ;;
        *)
  	        usage
  	        ;;
        esac
        ;;
    patch)
	    case $2 in
        backend)
            patch-backend
            ;;
        frontend)
            #patch-frontend 
            ;;
        *)
  	        usage
  	        ;;
        esac
        ;;
    delete)
        delete-workloads
        ;;
    *)
  	    usage
  	    ;;
    esac
}

#################### main #######################

source supply-chain/secrets/config-values.env
bold=$(tput bold)
normal=$(tput sgr0)

case $1 in
workload)
	workload $2 $3
    ;;
workflow)
    workflow $2
    ;;
rockme-native)
    rockme-native $2
    ;;
*)
  	usage
  	;;
esac
