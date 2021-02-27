#!/usr/bin/env bash

source secrets/config-values.env

export tss_client_server_uri=http://tss.apps.$SUB_DOMAIN.$DOMAIN

#generators
tss generator create-from-file --file=tss/dekt-starters/generator-none.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-boot-k8s-kubectl.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-boot-k8s-jpa.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-boot-k8s-kustomize.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-boot-knative-graalvm.yaml 
tss generator create-from-file --file=tss/dekt-starters/generator-boot-knative-jib.yaml 
tss generator create-from-file --file=tss/dekt-starters/generator-boot-cloudfoundry.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-docker-compose.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-web-k8s.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-steeltoe-k8s-skaffold.yaml
tss generator create-from-file --file=tss/dekt-starters/generator-steeltoe-azure-spring-cloud.yaml

#starters
tss starter create-from-file --file=tss/dekt-starters/starter-music-store-steeltoe.yaml 
tss starter create-from-file --file=tss/dekt-starters/starter-ebanking.yaml 
tss starter create-from-file --file=tss/dekt-starters/starter-todo-service.yaml
tss starter create-from-file --file=tss/dekt-starters/starter-function-kafka.yaml
tss starter create-from-file --file=tss/dekt-starters/starter-spring-jpa.yaml 
tss starter create-from-file --file=tss/dekt-starters/starter-ruby-simple.yaml 
tss starter create-from-file --file=tss/dekt-starters/starter-dotnet-aspnet-hello.yaml
tss starter create-from-file --file=tss/dekt-starters/starter-boot-function-knative.yaml 
tss starter create-from-file --file=tss/dekt-starters/starter-frontend-ux-for-online-stores.yaml 

