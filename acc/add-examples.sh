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

    GENERATORS_FILES=("boot-api-k8s" "boot-k8s-kubectl" "boot-k8s-jpa" "boot-k8s-kustomize" "boot-knative-graalvm" "boot-knative-jib" "boot-cloudfoundry" "docker-compose" "web-k8s" "steeltoe-k8s-skaffold" "steeltoe-azure-spring-cloud")
    ACCELERATORS_FILES=("music-store-steeltoe" "ebanking" "todo-service" "function-kafka" "spring-jpa" "ruby-simple" "dotnet-aspnet-hello" "boot-function-knative" "frontend-ux-for-online-stores")

    import-files
}

#add dotnet examples
add-dotnet-examples() {

    GENERATORS_FILES=("boot-api-k8s" "web-k8s" "aks-resource-simple" "boot-aks-data" "boot-asc" "boot-function-azure" "boot-cloudfoundry" "docker-compose" "dotnet-web-azure" "kubernetes-steeltoe-skaffold" "steeltoe-asc" "boot-knative-graalvm")
    ACCELERATORS_FILES=("dotnet-SQLServer-EFCore" "music-store-steeltoe" "todo-service-asc" "jpa-sqlserver" "spring-cosmosdb-jpa" "dotnet-aspnet-hello" "boot-function-azure" "frontend-ux-for-online-stores")

    import-files
}

#import-files
import-files() {

    for i in ${!GENERATORS_FILES[@]}; do
        acc generator create-from-file --file=acc/examples/generators/${GENERATORS_FILES[$i]}.yaml
    done

    for i in ${!ACCELERATORS_FILES[@]}; do
        acc accelerator create-from-file --file=acc/examples/accelerators/${ACCELERATORS_FILES[$i]}.yaml
    done
}


case $1 in
spring)
    init $2
    add-spring-examples
    ;;
dotnet)
    init $2
    add-dotnet-examples
    ;;
*)
    echo "Incorrect usage. Please specify spring | dotnet"
    ;;
esac