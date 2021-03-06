#!/usr/bin/env bash

source secrets/config-values.env

export acc_client_server_uri=http://acc.$SUB_DOMAIN.$DOMAIN

acc login -u admin -p admin

#generators
acc generator create-from-file --file=acc/msft-examples/generator-aks-resource-simple.yaml
acc generator create-from-file --file=acc/msft-examples/generator-boot-aks-data.yaml
acc generator create-from-file --file=acc/msft-examples/generator-boot-asc.yaml
acc generator create-from-file --file=acc/msft-examples/generator-boot-function-azure.yaml 
acc generator create-from-file --file=acc/msft-examples/generator-cloudfoundry.yaml
acc generator create-from-file --file=acc/msft-examples/generator-docker-compose.yaml
acc generator create-from-file --file=acc/msft-examples/generator-dotnet-web-azure.yaml
acc generator create-from-file --file=acc/msft-examples/generator-kubernetes-steeltoe-skaffold.yaml 
acc generator create-from-file --file=acc/msft-examples/generator-none.yaml
acc generator create-from-file --file=acc/msft-examples/generator-steeltoe-asc.yaml

#accelerator
acc accelerator create-from-file --file=acc/msft-examples/accelerator-music-store-steeltoe.yaml 
acc accelerator create-from-file --file=acc/msft-examples/accelerator-todo-service-asc.yaml
acc accelerator create-from-file --file=acc/msft-examples/accelerator-spring-cosmosdb-jpa.yaml 
acc accelerator create-from-file --file=acc/msft-examples/accelerator-dotnet-aspnet-hello.yaml
acc accelerator create-from-file --file=acc/msft-examples/accelerator-boot-function-azure.yaml 
acc accelerator create-from-file --file=acc/msft-examples/accelerator-frontend-ux-for-online-stores.yaml 

