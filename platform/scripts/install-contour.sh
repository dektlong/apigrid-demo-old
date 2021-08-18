#!/usr/bin/env bash

source secrets/config-values.env

echo
echo "=========> Install contour ingress controller ..."
echo
        
kubectl create ns contour-system

helm install dekt bitnami/contour \
    --namespace contour-system \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux

#kubectl apply -f https://projectcontour.io/quickstart/operator.yaml
#kubectl apply -f https://projectcontour.io/quickstart/contour-custom-resource.yaml

#we use a modified install yaml to set externalTrafficPolicy: Cluster (from the local default) due to issues on AKS
#kubectl apply -f supply-chain/k8s-builders/contour-install.yaml

#update-dns "envoy" "projectcontour" "*.$SUB_DOMAIN"
platform/scripts/update-dns.sh "dekt-contour-envoy" "contour-system" "*.$SUB_DOMAIN" 