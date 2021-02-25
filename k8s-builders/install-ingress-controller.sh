#!/usr/bin/env bash

NGINX_NAMESPACE="nginx-system"


#################### functions #######################

#install with loadbalancer available in your cluster
install-with-lb () {

    echo
    echo "=========> Install nginx ingress controller with loadbalancer configuration ..."
    echo

    # Add the ingress-nginx repository
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

    kubectl create ns $NGINX_NAMESPACE 

    # Use Helm to deploy an NGINX ingress controller
    helm install dekt4pets ingress-nginx/ingress-nginx \
        --namespace $NGINX_NAMESPACE \
        --set controller.replicaCount=2 \
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux
    
    update-dns
    
}

#install without loadbalancer available in your cluster
install-static-ip () {

    echo
    echo "=========> Install nginx ingress controller with static-ip configuration ..."
    echo

    ingress_static_ip=$(kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[0].status.addresses[?\(@.type==\"ExternalIP\"\)].address})

    # Use Helm to deploy an NGINX ingress controller with static ip

    helm install dekt4pets ingress-nginx/ingress-nginx \
        --namespace $NGINX_NAMESPACE 
        --set controller.replicaCount=2 \
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux
        --set service.externalIPs[0]=$ingress_static_ip

    update-dns

}

#update dns
update-dns () {
    
    echo
    echo "====> Updating your DNS ..."
    echo
    
    echo
    printf "Waiting for ingress controller to receive public IP address from loadbalancer ."

    ingress_public_ip=""

    while [ "$ingress_public_ip" == "" ]
    do
	    printf "."
	    ingress_public_ip="$(kubectl get svc dekt4pets-ingress-nginx-controller -n $NGINX_NAMESPACE  -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')"
	    sleep 1
    done
    
    echo

    record_name="*.apps"
    api_sso_key="$GODADDY_API_KEY:$GODADDY_API_SECRET"
    update_domain_api_call="https://api.godaddy.com/v1/domains/dekt.io/records/A/$record_name"

    echo "updating this A record in GoDaddy:  $record_name.dekt.io --> $ingress_public_ip..."

    # Create DNS A Record
    curl -X PUT -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: sso-key $api_sso_key" "$update_domain_api_call" -d "[{\"data\": \"$ingress_public_ip\"}]"
}


#################### main #######################

source secrets/config-values.env

case $1 in
with-lb)
	install-with-lb
    ;;
without-lb)
    install-without-lb
	;;
*)
  	echo "Incorrect usage. Please specify: with-lb | without-lb "
    exit 
  	;;
esac