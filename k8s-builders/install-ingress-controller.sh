#!/usr/bin/env bash

#################### functions #######################

#install with loadbalancer available in your cluster
install-with-lb () {

    echo
    echo "=========> Install nginx ingress controller with loadbalancer configuration ..."
    echo

    # Add the ingress-nginx repository
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

    # Use Helm to deploy an NGINX ingress controller
    helm install dekt4pets ingress-nginx/ingress-nginx \
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
	    ingress_public_ip="$(kubectl get svc $APP_NAME-ingress-nginx-controller -n nginx-system -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')"
	    sleep 1
    done
    
    echo "updating this A record: $APP_RECORD_NAME.$APP_DOMAIN --> $ingress_public_ip using this API call $DNS_PROVIDER_DOMAIN_UPDATE_API_URI..."

    # Create DNS A Record
    curl -X PUT -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: sso-key $DNS_PROVIDER_API_KEY:$DNS_PROVIDER_API_SECRET" "$DNS_PROVIDER_DOMAIN_UPATE_API_URI/$DOMAIN/records/A/$RECORD_NAME" -d "[{\"data\": \"$ingress_public_ip\"}]"
}

#incorrect usage
incorrect-usage() {
	echo "Incorrect usage. Required: private-helm-staticIP | private-helm-LB | public-helm"
  	exit   
}

#################### main #######################

source secrets/config-values.txt

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