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
spring)
    init $2
    ACCELERATORS_FILES=("frontend-ux-for-online-stores" "backend-api-for-online-stores" \
                        "supplychain-dataservices" "supplychain-microservices" "supplychain-api-gateways" \
                        "music-store-steeltoe" "ebanking"  "todo-service" \
                        "function-kafka" "spring-jpa" "ruby-simple" "dotnet-aspnet-hello" "boot-function-knative")
    import-accelerators
    ;;
dotnet)
    init $2
    ACCELERATORS_FILES=("frontend-ux-for-online-stores" "backend-api-for-online-stores" \
                        "supplychain-dataservices" "supplychain-microservices" "supplychain-api-gateways" \
                        "music-store-steeltoe" "ebanking" "todo-service-asc" \ 
                        "dotnet-SQLServer-EFCore" "jpa-sqlserver" "spring-cosmosdb-jpa" "dotnet-aspnet-hello" "boot-function-azure")
    import-accelerators
    ;;
*)
    echo "Incorrect usage. Please specify spring | dotnet"
    ;;
esac
