#!/usr/bin/env bash

#simple pipeline to deploy app components, gateways and routes using Tanzu Build Service, Spring Cloud Gateway and Kustomize

case $1 in

deploy)
  kp image create dekt4pets-backend -n dekt4pets \
    --tag goharbor.io/dekt4pets/dekt4pets-backend:0.0.1 \
    --git https://github.com/dektlong/store-backend-api \
    --git-revision main \
    --builder dekt4pets-builder \
    --wait
  
  kp image create dekt4pets-frontend -n dekt4pets \
    --tag goharbor.io/dekt4pets/dekt4pets-frontend:0.0.1 \
    --git https://github.com/dektlong/store-frontend-ux \
    --git-revision main \
    --builder dekt4pets-builder \
     --wait
  
  kustomize build api-grid | kubectl apply -f -
  ;;

patch)
  kp image patch dekt4pets-backend
  
  kp image patch dekt4pets-frontend
  
  kustomize build api-grid | kubectl apply -f -
  ;;

delete)
  kustomize build api-grid | kubectl delete -f -
  
  kp image delete dekt4pets-backend
  
  kp image delete dekt4pets-frontend

*)
  # incorrect usage
  ;;
esac
