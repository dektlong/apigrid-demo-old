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
    kustomize build workloads/dekt4pets/backend | kubectl apply -f -
    
}

#deploy-frontend 
deploy-frontend() {
	
    echo
    echo "=========> Apply frontend app, service and routes ..."
    echo
	
    kustomize build workloads/dekt4pets/frontend | kubectl apply -f -

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
    
    #apply new routes so you can show them in portal while new build is happening
    kubectl apply -f workloads/dekt4pets/backend/routes/dekt4pets-backend-routes.yaml -n $APP_NAMESPACE >/dev/null &
    
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
    kubectl delete -f workloads/dekt4pets/backend/dekt4pets-backend-app.yaml -n $APP_NAMESPACE > /dev/null 
        
    kustomize build workloads/dekt4pets/backend | kubectl apply -f -

}

#deploy-fitness app
deploy-fitness () {

    pushd workloads/dektFitness

    kustomize build kubernetes-manifests/ | kubectl apply -f -
}

#rockme-native
deploy-rockme-native () {

 	kn service create rockme-native \
        --image $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/rockme:1.0.0 \
        --env TARGET="revision 1 of rockme-native" \
        --revision-name rockme-native-v1 \
        -n $APP_NAMESPACE 

    siege -d1  -c200 -t60S  --content-type="text/plain" 'http://rockme-native.dekt-apps.native.dekt.io POST rock-on'
}

update-rockme-native () {
 
    kn service update rockme-native \
        --image $IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/rockme:1.0.0 \
        --env TARGET="revision 2 of rockme-native" \
        --revision-name rockme-native-v2 \
        --traffic @latest=20,rockme-native-v1=80 \
        -n $APP_NAMESPACE 
}

#delete-workloads
delete-workloads() {

    echo
    echo "=========> Remove all workloads..."
    echo

    kustomize build workloads/dekt4pets/backend | kubectl delete -f -

    kustomize build workloads/dekt4pets/frontend | kubectl delete -f -  

    kustomize build workloads/dektFitness/kubernetes-manifests/ | kubectl delete -f -  

    kn service delete rockme-native -n $APP_NAMESPACE 

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
    echo "${bold}describe-workflows${normal}"
    echo
    echo "${bold}create-workload${normal}"
    echo "  dekt4pets-backend"
    echo "  dekt4pets-frontend"
    echo "  dektFitness"
    echo "  rockme-native"
    echo
    echo "${bold}update-workload${normal}"
    echo "  dekt4pets-backend"
    echo "  rockme-native"
    echo
  	exit   
 
}

#supply-chain
describe-workflow() {

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
    echo "      $DEMO_APP_GIT_REPO/workloads/dekt4pets/backend"
    echo "      $DEMO_APP_GIT_REPO/workloads/dekt4pets/frontend"
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
    echo "      workloads/dekt4pets/backend/routes/dekt4pets-backend-routes.yaml"
    echo "      workloads/dekt4pets/frontend/routes/dekt4pets-frontend-routes.yaml"
    echo
}

#create-workload
create-workload () {

    case $1 in
    dekt4pets-backend)
        deploy-backend
        ;;
    dekt4pets-frontend)
        deploy-frontend 
        ;;
    dektFitness)
        deploy-fitness
        ;;
    rockme-native)
        create-rockme-native
        ;;
    *)
  	    usage
  	    ;;
    esac
}

#################### main #######################

source secrets/config-values.env
bold=$(tput bold)
normal=$(tput sgr0)

case $1 in
create-workload)
	create-workload $2
    ;;
update-workload)
	update-workload $2
    ;;
delete)
    delete-workloads
    ;;
describe-workflows)
    describe-workflow
    ;;
*)
  	usage
  	;;
esac
