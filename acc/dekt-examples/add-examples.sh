#!/usr/bin/env bash

source secrets/config-values.env

export acc_client_server_uri=http://acc.$SUB_DOMAIN.$DOMAIN

acc login -u admin -p admin

#generators
acc generator create-from-file --file=acc/dekt-examples/generator-none.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-boot-k8s-kubectl.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-boot-k8s-jpa.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-boot-k8s-kustomize.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-boot-knative-graalvm.yaml 
acc generator create-from-file --file=acc/dekt-examples/generator-boot-knative-jib.yaml 
acc generator create-from-file --file=acc/dekt-examples/generator-boot-cloudfoundry.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-docker-compose.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-web-k8s.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-steeltoe-k8s-skaffold.yaml
acc generator create-from-file --file=acc/dekt-examples/generator-steeltoe-azure-spring-cloud.yaml

#accelerators
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-music-store-steeltoe.yaml 
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-ebanking.yaml 
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-todo-service.yaml
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-function-kafka.yaml
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-spring-jpa.yaml 
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-ruby-simple.yaml 
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-dotnet-aspnet-hello.yaml
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-boot-function-knative.yaml 
acc accelerator create-from-file --file=acc/dekt-examples/accelerator-frontend-ux-for-online-stores.yaml 

