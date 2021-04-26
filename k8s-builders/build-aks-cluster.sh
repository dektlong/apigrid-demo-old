#!/usr/bin/env bash

#################### functions #######################

#create cluster
#	params: cluster-name, number-of-nodes
create-cluster() {
	
	rm ~/.kube/config

	echo
	echo "==========> Creating AKS cluster named $1 with $2 nodes ..."
	echo
	
	az login -u $AZURE_USER -p $AZURE_PASSWORD
	
	az group create --name $RESOURCE_GROUP --location westus

	az aks create --resource-group $RESOURCE_GROUP --name $1 --node-count $2 --generate-ssh-keys

	az aks get-credentials --resource-group $RESOURCE_GROUP --name $1
}

#delete cluster
#	params: cluster name
delete-cluster() {
	
	az login -u $AZURE_USER -p $AZURE_PASSWORD

	echo
	echo "==========> Starting deletion of AKS cluster: $1"
	echo

	az group delete -n $RESOURCE_GROUP --yes --no-wait

	az aks delete --name $1 --resource-group $RESOURCE_GROUP --yes --no-wait

}

#incorrect usage
incorrect-usage() {
	
	echo "Incorrect usage. Required: create/delete , cluster-name  , number-of-worker-nodes"
	exit
}


#################### main #######################

source secrets/config-values.env

case $1 in 
create)
	create-cluster $2 $3
	open -a Terminal k8s-builders/start_octant.sh
	;;
delete)
	delete-cluster $2
  	;;
*)
  	incorrect-usage
  	;;
esac


