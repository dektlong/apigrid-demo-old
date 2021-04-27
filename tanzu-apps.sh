#!/usr/bin/env bash

bold=$(tput bold)
normal=$(tput sgr0)

#################### functions #######################

#deploy-backend 
deploy-backend() {
	
    echo
    echo "=========> Sync local code with remote git $DEMO_APP_GIT_REPO ..."
    echo
    git-push "local-development-completed"
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
    kustomize build workloads/backend | kubectl apply -f -
    
}

#deploy-frontend 
deploy-frontend() {
	
    echo
    echo "=========> Apply frontend app, service and routes ..."
    echo
	
    kustomize build workloads/frontend | kubectl apply -f -

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
    kubectl delete -f backend/dekt4pets-backend-app.yaml -n $APP_NAMESPACE > /dev/null 
        
    kustomize build backend | kubectl apply -f -

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
	echo "A mockup script to illustrate upcoming AppStack concepts. Please specify one of the following:"
	echo
    echo "${bold}supplychain${normal}"
    echo "  create"
    echo "  describe"
    echo
    echo "${bold}workload${normal}"
    echo "  create-backend" 
    echo "  create-frontend"
    echo "  patch-backend"
    echo
  	exit   
 
}

#supplychain
supplychain() {

    case $1 in
    describe)
    	echo
	    echo "The following supplychains mockup configurations have been applied to this cluster:"
	    echo
        echo "${bold}micro-gateways${normal}"
        echo "  {SourceTemplate} defining Dekt4Pets, BackgroundCheck, Donations and Suppliers gateways"
        echo
        echo "${bold}dekt4Pets${normal}"
        echo "  {SourceTemplate} defining Backend and Frontend microservices"
        echo "  {BuildTemplate} defining Java and kNative builders"
        echo "  {ConfigTemplate} defining Backend and Frontend api-routes"
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
    create-backend)
    	deploy-backend
        ;;
    create-frontend)
	    deploy-frontend
	    ;;
    patch-backend)
        patch-backend
        ;;
    *)
  	    usage
  	    ;;
    esac
}

#################### main #######################

source supplychain/secrets/config-values.env

case $1 in
workload)
	workload $2
    ;;
supplychain)
    supplychain $2
    ;;
rockme-native)
    rockme-native $2
    ;;
*)
  	usage
  	;;
esac
