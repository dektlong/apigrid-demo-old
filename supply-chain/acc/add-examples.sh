#!/usr/bin/env bash
source supply-chain/secrets/config-values.env
    
#init
init () {

    export tss_client_server_uri=http://$1.$SUB_DOMAIN.$DOMAIN

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
    init "acc-dev"
    ACCELERATORS_FILES=("frontend-ux-for-online-stores" "backend-api-for-online-stores" \
                        "music-store-steeltoe" "ebanking"  "todo-service" "todo-service-asc" \
                        "function-kafka" "spring-jpa" "ruby-simple" "dotnet-aspnet-hello" "boot-function-knative" \
                        "dotnet-SQLServer-EFCore" "jpa-sqlserver" "spring-cosmosdb-jpa" "boot-function-azure")
    import-accelerators
    ;;
devops)
    init "acc-devops"
    ACCELERATORS_FILES=("supplychain-dataservices" "supplychain-microservices" "supplychain-api-gateways")
    import-accelerators
    ;;
*)
    echo "Incorrect usage. Please specify dev | devops"
    ;;
esac
