#!/usr/bin/env bash

#init
init () {

    if  [ "$1" != "" ]; then 
        export tss_client_server_uri=$1 #remote server
    fi

    acc login -u admin -p admin
}

#add spring examples
add-spring-examples() {

    GENERATORS_FILES=("generator-boot-api-k8s.yaml" "generator-boot-k8s-kubectl.yaml" "generator-boot-k8s-jpa.yaml" "generator-boot-k8s-kustomize.yaml" "generator-boot-knative-graalvm.yaml" "generator-boot-knative-jib.yaml" "generator-boot-cloudfoundry.yaml" "generator-docker-compose.yaml" "generator-web-k8s.yaml" "generator-steeltoe-k8s-skaffold.yaml" "generator-steeltoe-azure-spring-cloud.yaml")
    ACCELERATORS_FILES=("accelerator-music-store-steeltoe.yaml" "accelerator-ebanking.yaml" "accelerator-todo-service.yaml" "accelerator-function-kafka.yaml" "accelerator-spring-jpa.yaml" "accelerator-ruby-simple.yaml" "accelerator-dotnet-aspnet-hello.yaml" "accelerator-boot-function-knative.yaml" "accelerator-frontend-ux-for-online-stores.yaml")

    import-files
}

#add azure examples
add-azure-examples() {

    GENERATORS_FILES=("generator-aks-resource-simple.yaml" "generator-boot-aks-data.yaml" "generator-boot-asc.yaml" "generator-boot-function-azure.yaml" "generator-cloudfoundry.yaml" "generator-docker-compose.yaml" "generator-dotnet-web-azure.yaml" "generator-kubernetes-steeltoe-skaffold.yaml" "generator-none.yaml" "generator-steeltoe-asc.yaml")
    ACCELERATORS_FILES==("accelerator-music-store-steeltoe.yaml" "accelerator-todo-service-asc.yaml" "accelerator-spring-cosmosdb-jpa.yaml" "accelerator-dotnet-aspnet-hello.yaml" "accelerator-boot-function-azure.yaml" "accelerator-frontend-ux-for-online-stores.yaml")

    import-files
}

#import-files
import-files() {

    for i in ${!GENERATORS_FILES[@]}; do
        acc generator create-from-file --file=acc/examples/generators/${GENERATORS_FILES[$i]}
    done

    for i in ${!ACCELERATORS_FILES[@]}; do
        acc accelerator create-from-file --file=acc/examples/accelerators/${ACCELERATORS_FILES[$i]}
    done
}


case $1 in
spring)
    init $2
    add-spring-examples
    ;;
azure)
    init $2
    add-azure-examples
    ;;
dotnet)
    init $2
    add-dotnet-examples
    ;;
*)
    echo "Incorrect usage. Please specify spring | azure | dotnet"
    ;;
esac