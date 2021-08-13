#!/usr/bin/env bash

#################### functions #######################

#create cluster
create-cluster() {
	
	clusterName=$1
	
	numberOfNodes=7
	nodeSize="Standard_DS3_v2" # 4 vCPU, 14GB memory, 28GB temp disk
	
	echo
	echo "==========> Creating AKS cluster named $clusterName with $numberOfNodes nodes of size $nodeSize ..."
	echo
	
	az login -u $AZURE_USER -p $AZURE_PASSWORD --allow-no-subscriptions
	
	az group create --name $RESOURCE_GROUP --location westus

	az aks create --resource-group $RESOURCE_GROUP --name $clusterName --node-count $numberOfNodes --node-vm-size $nodeSize --generate-ssh-keys

	az aks get-credentials --overwrite-existing --resource-group $RESOURCE_GROUP --name $1
}

delete-cluster() {
	
	clusterName=$1

	az login -u $AZURE_USER -p $AZURE_PASSWORD

	echo
	echo "==========> Starting deletion of AKS cluster named $clusterName"
	echo

	az aks delete --name $clusterName --resource-group $RESOURCE_GROUP --yes --no-wait

}

#start-octant
start-octant() {

	open -a Terminal supply-chain/k8s-builders/octant-wrapper.sh
        
    osascript -e 'tell application "Terminal" to set miniaturized of every window to true'
}

stop-octant() {
	procid=$(pgrep octant)
    if [ "$procid" == "" ]
    then
        echo "octant process is not running"
    else 
        kill $procid
        osascript -e 'quit app "Terminal"'
    fi
}

#incorrect usage
incorrect-usage() {
	
	echo "Incorrect usage. Required: create {cluster-name,number-of-worker-nodes} | delete {cluster-name}"
	exit
}


#################### main #######################

source secrets/config-values.env

case $1 in 
create)
	create-cluster $2 $3
	start-octant
	;;
delete)
	delete-cluster $2
	stop-octant
  	;;
*)
  	incorrect-usage
  	;;
esac


