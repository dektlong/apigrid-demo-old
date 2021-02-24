
# dekt4Pets ♥️😺 ♥️🐶

This repo contains artifacts to run a demo illustrating the vision of Tanzu Micro API Fabric on any k8s substrate.

## Curated Start                                                   
- Architects create patterns                                      
- Devs start quickly via curated ‘starters’                           
- API-first design boiler-plate code                                  

## Consistent Builds                                                    
- Local dev to pipeline-initiated builds                          
- Follows standard Boot tools (no docker files required               
- Prod-optimized images, air-gaped artifacts, lifecyle support        

## Collaborative micro-APIs 
- Deploy backend service and expose its internal APIs through a dev-friendly 'app' Gateway, including simple to use SSO
- Frontend devs discover, test and reuse backend APIs via an auto-populated Hub
- Backend team add 'backgroud-checks' leveraging 'brownfield APIs' from off-platform services 
- Publish app and configure live traffic via the gateway

## COMPLETE BEFORE STARTING !!

1. Update with your own values

2. Create a 'secrets' folder

3. Create secrets/dekt4pets-jwk.txt & secrets/dekt4pets-sso.txt credential files
    (see example in https://github.com/spring-cloud-services-samples/animal-rescue/blob/main/k8s/deploy_to_k8s.md)

4. Rename and move config-values-UPDATE_ME.txt to secrets/config-values.txt

5. Set all variables in config-values.txt

6. update image locations in deployment yamls

## Installing the demo

- ./init-demo [aks | tkg]

## Running the demo

- access TSS
- run-pipeline info 

# Enjoy!
