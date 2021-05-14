#!/usr/bin/env bash

#init
init () {

    if  [ "$1" != "" ]; then 
        export tss_client_server_uri=$1 #remote server
    fi

    acc login -u admin -p admin
}

#import-accelerators
import-accelerators() {

    for i in ${!ACCELERATORS_FILES[@]}; do
        acc accelerator create-from-file --file=supply-chain/acc/accelerators/${ACCELERATORS_FILES[$i]}.yaml
    done
}


case $1 in
dev)
    init $2
    ACCELERATORS_FILES=("frontend-ux-for-online-stores" "backend-api-for-online-stores" \
                        "music-store-steeltoe" "ebanking"  "todo-service" "todo-service-asc" \
                        "function-kafka" "spring-jpa" "ruby-simple" "dotnet-aspnet-hello" "boot-function-knative" \
                        "dotnet-SQLServer-EFCore" "jpa-sqlserver" "spring-cosmosdb-jpa" "dotnet-aspnet-hello" "boot-function-azure")
    import-accelerators
    ;;
devops)
    init $2
    ACCELERATORS_FILES=("supplychain-dataservices" "supplychain-microservices" "supplychain-api-gateways")
    import-accelerators
    ;;
*)
    echo "Incorrect usage. Please specify dev | devops"
    ;;
esac
