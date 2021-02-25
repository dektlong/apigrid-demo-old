#!/usr/bin/env bash

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
    echo "=========> Start micro-gateway for dekt4pets app..."
    echo
    kustomize build gateway | kubectl apply -f -

    echo
    echo "=========> Apply backend app, service and routes ..."
    echo    
    #kubectl set image deployment/dekt4pets-backend dekt4pets-backend=$IMG_REGISTRY_URL/$IMG_REGISTRY_APP_REPO/$BACKEND_TBS_IMAGE:$APP_VERSION -n $APP_NAMESPACE
    kustomize build backend | kubectl apply -f -
    
}

#deploy-frontend 
deploy-frontend() {
	
    echo
    echo "=========> Apply frontend app, service and routes ..."
    echo
	
    kustomize build frontend | kubectl apply -f -

}

#open-store (enable external traffic on gateway)
open-store() {

	echo
	echo "=========> Open dekt4pets online store: Configure external traffic via dekt4pets-gateway ..."
	echo

	kubectl apply -f gateway/dekt4pets-ingress.yaml -n $APP_NAMESPACE
	
	echo
    printf "Waiting for ingress rule to receive IP address ."

	ingress_ip=""

	while [ "$ingress_ip" == "" ]
	do
		printf "."
		ingress_ip="$(kubectl get ingress dekt4pets-ingress -n $APP_NAMESPACE -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')"
		sleep 1
	done

	echo
	kubectl get ingress dekt4pets-ingress -n $APP_NAMESPACE

	echo
	echo "The dekt4pets application should now be accessible on https://dekt4pets.apps.$DNS_PROVIDER_DOMAIN/rescue "
	echo
}

#patch-backend
# input change commit message
patch-backend() {
    
    if  [ "$1" == "" ]; then 
        echo
	    echo "Incorrect usage. A message for this git commit is required."
	    echo
        exit
    fi
    
    echo
    echo "=========> Commit code changes to $DEMO_APP_GIT_REPO  ..."
    echo
    git-push "$1"
    
    echo
    echo "=========> Auto-build $BACKEND_TBS_IMAGE image on latest git commit (commit: $_latestCommitId) ..."
    echo
    
    kp image patch $BACKEND_TBS_IMAGE --git-revision $_latestCommitId -n $APP_NAMESPACE
    
    echo
    echo "Waiting for next github polling interval ..."
    echo  
    
    sleep 20 #enough time, instead of active polling which is not recommended by the TBS team
    
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

#info
info() {
	echo
	echo "========== dekt4pets pipeline (‘the path to prod’) ==========  " 
    read
    echo  "(1) deploy backend microservice " 
    echo    "  => commit local code to git" 
    echo    "  => build will automatically start in the background if input changes (source code, base-os, or buildpacks)" 
    echo    "  => create the dekt4pets micro-gateway instance"
    echo    "  => apply backend app, service and routes"
    read
    echo "(2) deploy frontend microservice"
    echo    "  => apply frontend app, service and routes"
    read
    echo "(3) enable external traffic"
    echo    "  => add an ingress rule to dekt4pets micro-gateway"
    read
    echo "(4) patch backend microservice"
    echo    "  => commit code change to git" 
    echo    "  => build will start automatically, pipeline waits for build complete while trailing its logs" 
    echo    "  => apply changes to backend app, service and routes"
    read
    echo "let's go!"
    echo
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

#incorrect usage
incorrect-usage() {
	echo
	echo "Incorrect usage. Please specify one of the following:"
	echo
  	echo "* deploy-backend"
	echo "* deploy-frontend"
	echo "* open-store"
    echo "* patch-backend { required: git-commit-message } "
    echo "* info"
   	echo
  	exit   
 
}

#################### main #######################

source secrets/config-values.txt

case $1 in
deploy-backend)
	deploy-backend 
    ;;
deploy-frontend)
	deploy-frontend
	;;
open-store)
	open-store
	;;
patch-backend)
    patch-backend "$2"
    ;;
info)
    info
    ;;
*)
  	incorrect-usage
  	;;
esac