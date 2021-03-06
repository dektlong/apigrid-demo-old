#!/usr/bin/env bash

source secrets/config-values.env

export tss_client_server_uri=http://tss.$SUB_DOMAIN.$DOMAIN

#generators
tss generator create-from-file --file=tss/msft-starters/generator-aks-resource-simple.yaml
tss generator create-from-file --file=tss/msft-starters/generator-boot-aks-data.yaml
tss generator create-from-file --file=tss/msft-starters/generator-boot-asc.yaml
tss generator create-from-file --file=tss/msft-starters/generator-boot-function-azure.yaml 
tss generator create-from-file --file=tss/msft-starters/generator-cloudfoundry.yaml
tss generator create-from-file --file=tss/msft-starters/generator-docker-compose.yaml
tss generator create-from-file --file=tss/msft-starters/generator-dotnet-web-azure.yaml
tss generator create-from-file --file=tss/msft-starters/generator-kubernetes-steeltoe-skaffold.yaml 
tss generator create-from-file --file=tss/msft-starters/generator-none.yaml
tss generator create-from-file --file=tss/msft-starters/generator-steeltoe-asc.yaml

#starters
tss starter create-from-file --file=tss/msft-starters/starter-music-store-steeltoe.yaml 
tss starter create-from-file --file=tss/msft-starters/starter-todo-service-asc.yaml
tss starter create-from-file --file=tss/msft-starters/starter-spring-cosmosdb-jpa.yaml 
tss starter create-from-file --file=tss/msft-starters/starter-dotnet-aspnet-hello.yaml
tss starter create-from-file --file=tss/msft-starters/starter-boot-function-azure.yaml 
tss starter create-from-file --file=tss/msft-starters/starter-frontend-ux-for-online-stores.yaml 

